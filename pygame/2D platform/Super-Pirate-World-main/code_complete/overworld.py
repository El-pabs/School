# Import necessary modules and settings
from settings import *
from sprites import Sprite, AnimatedSprite, Node, Icon, PathSprite
from groups import WorldSprites
from random import randint

# Define the Overworld class
class Overworld:
    # Initialize the Overworld
    def __init__(self, tmx_map, data, overworld_frames, switch_stage):
        # Get the display surface
        self.display_surface = pygame.display.get_surface()
        # Store the game data
        self.data = data
        # Store the function to switch stages
        self.switch_stage = switch_stage

        # Create sprite groups
        self.all_sprites = WorldSprites(data)
        self.node_sprites = pygame.sprite.Group()

        # Setup the Overworld
        self.setup(tmx_map, overworld_frames)

        # Get the current node
        self.current_node = [node for node in self.node_sprites if node.level == 0][0]

        # Get the path frames
        self.path_frames = overworld_frames['path']
        # Create path sprites
        self.create_path_sprites()

    # Setup the Overworld
    def setup(self, tmx_map, overworld_frames):
        # Create tiles
        for layer in ['main', 'top']:
            for x, y, surf in tmx_map.get_layer_by_name(layer).tiles():
                Sprite((x * TILE_SIZE,y * TILE_SIZE), surf, self.all_sprites, Z_LAYERS['bg tiles'])

        # Create water
        for col in range(tmx_map.width):
            for row in range(tmx_map.height):
                AnimatedSprite((col * TILE_SIZE,row * TILE_SIZE), overworld_frames['water'], self.all_sprites, Z_LAYERS['bg'])

        # Create objects
        for obj in tmx_map.get_layer_by_name('Objects'):
            if obj.name == 'palm':
                AnimatedSprite((obj.x, obj.y), overworld_frames['palms'], self.all_sprites, Z_LAYERS['main'], randint(4,6))
            else:
                z = Z_LAYERS[f'{'bg details' if obj.name == 'grass' else 'bg tiles'}']
                Sprite((obj.x, obj.y), obj.image, self.all_sprites, z)

        # Create paths
        self.paths = {}
        for obj in tmx_map.get_layer_by_name('Paths'):
            pos = [(int(p.x + TILE_SIZE / 2),int( p.y + TILE_SIZE / 2)) for p in obj.points]
            start = obj.properties['start']
            end  = obj.properties['end']
            self.paths[end] = {'pos': pos, 'start': start}

        # Create nodes & player
        for obj in tmx_map.get_layer_by_name('Nodes'):
            # Create player
            if obj.name == 'Node' and obj.properties['stage'] == self.data.current_level:
                self.icon = Icon((obj.x + TILE_SIZE / 2, obj.y + TILE_SIZE / 2), self.all_sprites, overworld_frames['icon'])

            # Create nodes
            if obj.name == 'Node':
                available_paths = {k:v for k,v in obj.properties.items() if k in ('left', 'right', 'up', 'down')}
                Node(
                    pos = (obj.x, obj.y),
                    surf = overworld_frames['path']['node'],
                    groups = (self.all_sprites, self.node_sprites),
                    level = obj.properties['stage'],
                    data = self.data,
                    paths = available_paths)

    # Create path sprites
    def create_path_sprites(self):
        # Get tiles from path
        nodes = {node.level: vector(node.grid_pos) for node in self.node_sprites}
        path_tiles = {}

        for path_id, data in self.paths.items():
            path = data['pos']
            start_node, end_node = nodes[data['start']], nodes[path_id]
            path_tiles[path_id] = [start_node]

            for index, points in enumerate(path):
                if index < len(path) - 1:
                    start, end = vector(points), vector(path[index + 1])
                    path_dir = (end - start) / TILE_SIZE
                    start_tile = vector(int(start[0]/ TILE_SIZE), int(start[1]/ TILE_SIZE))

                    if path_dir.y:
                        dir_y = 1 if path_dir.y > 0 else -1
                        for y in range(dir_y, int(path_dir.y) + dir_y, dir_y):
                            path_tiles[path_id].append(start_tile + vector(0,y))

                    if path_dir.x:
                        dir_x = 1 if path_dir.x > 0 else -1
                        for x in range(dir_x, int(path_dir.x) + dir_x, dir_x):
                            path_tiles[path_id].append(start_tile + vector(x,0))

            path_tiles[path_id].append(end_node)

        # Create sprites
        for key, path in path_tiles.items():
            for index, tile in enumerate(path):
                if index > 0 and index < len(path) - 1:
                    prev_tile = path[index - 1] - tile
                    next_tile = path[index + 1] - tile

                    if prev_tile.x == next_tile.x:
                        surf = self.path_frames['vertical']
                    elif prev_tile.y == next_tile.y:
                        surf = self.path_frames['horizontal']
                    else:
                        if prev_tile.x == -1 and next_tile.y == -1 or prev_tile.y == -1 and next_tile.x == -1:
                            surf = self.path_frames['tl']
                        elif prev_tile.x == 1 and next_tile.y == 1 or prev_tile.y == 1 and next_tile.x == 1:
                            surf = self.path_frames['br']
                        elif prev_tile.x == -1 and next_tile.y == 1 or prev_tile.y == 1 and next_tile.x == -1:
                            surf = self.path_frames['bl']
                        elif prev_tile.x == 1 and next_tile.y == -1 or prev_tile.y == -1 and next_tile.x == 1:
                            surf = self.path_frames['tr']
                        else:
                            surf = self.path_frames['horizontal']

                    PathSprite(
                        pos = (tile.x * TILE_SIZE, tile.y * TILE_SIZE),
                        surf = surf,
                        groups = self.all_sprites,
                        level = key)

    # Handle input
    def input(self):
        keys = pygame.key.get_pressed()
        if self.current_node and not self.icon.path:
            if keys[pygame.K_DOWN] and self.current_node.can_move('down'):
                self.move('down')
            if keys[pygame.K_LEFT] and self.current_node.can_move('left'):
                self.move('left')
            if keys[pygame.K_RIGHT] and self.current_node.can_move('right'):
                self.move('right')
            if keys[pygame.K_UP] and self.current_node.can_move('up'):
                self.move('up')
            if keys[pygame.K_RETURN]:
                self.data.current_level = self.current_node.level
                self.switch_stage('level')

    # Move the player
    def move(self, direction):
        path_key = int(self.current_node.paths[direction][0])
        path_reverse = True if self.current_node.paths[direction][-1] == 'r' else False
        path = self.paths[path_key]['pos'][:] if not path_reverse else self.paths[path_key]['pos'][::-1]
        self.icon.start_move(path)

    # Get the current node
    def get_current_node(self):
        nodes = pygame.sprite.spritecollide(self.icon, self.node_sprites, False)
        if nodes:
            self.current_node = nodes[0]

    # Run the Overworld
    def run(self, dt):
        self.input()
        self.get_current_node()
        self.all_sprites.update(dt)
        self.all_sprites.draw(self.icon.rect.center)