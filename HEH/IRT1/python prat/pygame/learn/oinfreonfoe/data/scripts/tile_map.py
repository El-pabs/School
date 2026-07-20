import json
import math
import random
import time

import pygame

from data.scripts.quads import Quads

SURROUND_POS = [
    [-1, 0],
    [0, 0],
    [1, 0],
    [-1, -1],
    [0, -1],
    [1, -1],
    [-1, 1],
    [0, 1],
    [1, 1],
]

SURROUND_POS = []
for p in [[[x - 2, y - 2] for x in range(5)] for y in range(5)]:
    SURROUND_POS += p

add_index = 0

def tuple_to_str(tp):
    return ';'.join([str(v) for v in tp])

def str_to_tuple(s):
    return tuple([int(v) for v in s.split(';')])

class TileMap:
    def __init__(self, tile_size, view_size):
        self.tile_size = tuple(tile_size)
        self.view_size = tuple(view_size)
        self.tile_map = {}
        self.tile_map_off_grid = {}
        self.all_layers = []
        self.dropthroughs = []
        self.off_grid_quads = Quads(128)

    # used after converting from json
    def tuplify(self):
        new_tile_map = {}
        new_tile_map_off_grid = {}
        for pos in self.tile_map:
            new_tile_data = {}
            for layer in self.tile_map[pos]:
                new_tile_data[int(layer)] = self.tile_map[pos][layer]
            new_tile_map[str_to_tuple(pos)] = new_tile_data
        for layer in self.tile_map_off_grid:
            new_tile_map_off_grid[int(layer)] = self.tile_map_off_grid[layer]
        self.tile_map = new_tile_map
        self.tile_map_off_grid = new_tile_map_off_grid

    # used when converting to json
    def stringify(self):
        new_tile_map = {}
        for pos in self.tile_map:
            new_tile_map[tuple_to_str(pos)] = self.tile_map[pos]
        self.tile_map = new_tile_map

    def load_map(self, path):
        f = open(path, 'r')
        dat = f.read()
        f.close()
        json_dat = json.loads(dat)
        self.tile_map = json_dat['map']
        self.tile_map_off_grid = json_dat['off_grid_map']
        self.all_layers = json_dat['all_layers']
        for layer in self.tile_map_off_grid:
            for tile in self.tile_map_off_grid[layer]:
                if tile['type'][0] != 'entities':
                    self.off_grid_quads.add_raw((layer, tile), pygame.Rect(*tile['raw'][0], 90, 90))

        self.tuplify()
        self.clean()

    def load_grass(self, gm):
        grass_filter = lambda x: x['type'][0] == 'grass'
        for tile in self.tile_filter(grass_filter):
            gm.place_tile(tile[0], random.randint(4, 8), [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 6])

    def load_entities(self):
        entity_filter = lambda x: x['type'][0] in ['entities']
        tiles = []
        for tile in self.tile_filter(entity_filter):
            tiles.append(tile)
        return tiles

    def load_dropthroughs(self):
        dropthrough_filter = lambda x: (x['type'][0] == 'functionals')
        for tile in self.tile_filter(dropthrough_filter, skip_grid_tiles=True):
            self.dropthroughs.append(([tile[2]['type']], pygame.Rect(tile[0][0], tile[0][1], *self.tile_size)))

    def clean(self):
        remove_list = []
        for tile in self.tile_map:
            if not len(self.tile_map[tile]):
                remove_list.append(tile)

        for tile in remove_list:
            del self.tile_map[tile]

    def tile_filter(self, filter_func, skip_grid_tiles=False):
        matched_tiles = []
        matched_off_grid_tiles = []
        if not skip_grid_tiles:
            for pos in self.tile_map:
                for layer in self.tile_map[pos]:
                    tile_data = self.tile_map[pos][layer]
                    match = filter_func(tile_data)
                    if match:
                        matched_tiles.append((pos, layer, tile_data))

        for layer in self.tile_map_off_grid:
            for i, tile in sorted(enumerate(self.tile_map_off_grid[layer]), reverse=True):
                match = filter_func(tile)
                if match:
                    matched_off_grid_tiles.append((tile['pos'], layer, tile))
                    if (tile['type'][0] == 'entities') and (tile['type'][1] == 2):
                        continue
                    self.tile_map_off_grid[layer].pop(i)

        for tile in matched_tiles:
            del self.tile_map[tile[0]][tile[1]]
            if not len(self.tile_map[tile[0]]):
                del self.tile_map[tile[0]]

        return matched_tiles + matched_off_grid_tiles

    def write_map(self, path):
        self.stringify()
        json_dat = {
            'map': self.tile_map,
            'off_grid_map': self.tile_map_off_grid,
            'all_layers': self.all_layers,
        }
        self.tuplify()
        f = open(path, 'w')
        f.write(json.dumps(json_dat))
        f.close()

    # position is in pixels
    def get_nearby_rects(self, pos):
        tile_pos = (int(pos[0] // self.tile_size[0]), int(pos[1] // self.tile_size[1]))
        rects = []
        for p in SURROUND_POS:
            check_loc = (tile_pos[0] + p[0], tile_pos[1] + p[1])
            if check_loc in self.tile_map:
                tile_list = []
                for l in self.tile_map[check_loc]:
                    if self.tile_map[check_loc][l]['type'][0] == 'tiles':
                        tile_list.append(self.tile_map[check_loc][l]['type'])
                if len(tile_list):
                    rects.append((tile_list, pygame.Rect(check_loc[0] * self.tile_size[0], check_loc[1] * self.tile_size[1], self.tile_size[0], self.tile_size[1])))
        return rects

    # position is in pixels
    def tile_collide(self, pos):
        tile_pos = (int(pos[0] // self.tile_size[0]), int(pos[1] // self.tile_size[1]))
        if tile_pos in self.tile_map:
            for layer in self.tile_map[tile_pos]:
                if self.tile_map[tile_pos][layer]['type'][0] in ['tiles']:
                    return True
        return False

    def get_tile(self, pos, target_layer=None):
        pos = tuple(pos)
        if pos in self.tile_map:
            if target_layer != None:
                if target_layer in self.tile_map[pos]:
                    return self.tile_map[pos][target_layer]
                else:
                    return None
            else:
                return self.tile_map[pos]
        else:
            return None

    def add_off_grid_tile(self, tile_type, pos, layer):
        global add_index
        if layer not in self.all_layers:
            self.all_layers.append(layer)
            self.all_layers.sort()

        if layer not in self.tile_map_off_grid:
            self.tile_map_off_grid[layer] = []
        self.tile_map_off_grid[layer].append({'pos': list(pos), 'type': tile_type, 'raw': [list(pos), tile_type]})

        if tile_type[0] == 'entities':
            self.tile_map_off_grid[layer][-1]['entity_id'] = int(time.time() * 100 + add_index * 10000)
            add_index += 1

    def add_tile(self, tile_type, pos, layer):
        global add_index
        pos = tuple(pos)
        if pos in self.tile_map:
            self.tile_map[pos][layer] = {'pos': list(pos), 'type': tile_type, 'raw': [[pos[0] * self.tile_size[0], pos[1] * self.tile_size[1]], tile_type]}
        else:
            self.tile_map[pos] = {layer: {'pos': list(pos), 'type': tile_type, 'raw': [[pos[0] * self.tile_size[0], pos[1] * self.tile_size[1]], tile_type]}}

        if tile_type[0] == 'entities':
            self.tile_map[pos][layer]['entity_id'] = int(time.time() * 100 + add_index * 10000)
            add_index += 1

        if layer not in self.all_layers:
            self.all_layers.append(layer)
            self.all_layers.sort()

    def remove_tile(self, pos, layer=None):
        pos = tuple(pos)
        if pos in self.tile_map:
            if layer != None:
                if layer in self.tile_map[pos]:
                    tile_data = self.tile_map[pos][layer]
                    del self.tile_map[pos][layer]
                    return tile_data
            else:
                tile_data = self.tile_map[pos][layer]
                del self.tile_map[pos]
                return tile_data

    def remove_off_grid_tiles(self, rect, layer=None):
        remove_list = []
        removed_data = []
        if layer == None:
            layer_list = self.all_layers.copy()
        else:
            layer_list = [layer]

        for layer in layer_list:
            for i, tile in sorted(enumerate(self.tile_map_off_grid[layer]), reverse=True):
                tile_r = pygame.Rect(tile['raw'][0][0], tile['raw'][0][1], self.tile_size[0], self.tile_size[1])
                if tile_r.colliderect(rect):
                    removed_data.append(self.tile_map_off_grid[layer][i])
                    self.tile_map_off_grid[layer].pop(i)

        return removed_data

    def get_visible(self, pos, size_override=None):
        size = self.view_size
        if size_override:
            size = size_override

        layers = {l : [] for l in self.all_layers}
        for y in range(math.ceil(size[1] / self.tile_size[1]) + 1):
            for x in range(math.ceil(size[0] / self.tile_size[0]) + 1):
                tile_pos = (x + int(round(pos[0] / self.tile_size[0] - 0.5, 0)), y + int(round(pos[1] / self.tile_size[1] - 0.5, 0)))
                if tile_pos in self.tile_map:
                    for tile in self.tile_map[tile_pos]:
                        layers[tile].append(self.tile_map[tile_pos][tile]['raw'] + ([self.tile_map[tile_pos][tile]['entity_id']] if 'entity_id' in self.tile_map[tile_pos][tile] else []))

        off_grid_tiles = self.off_grid_quads.query(pygame.Rect(pos[0], pos[1], *size))
        for tile in off_grid_tiles:
            layers[int(tile[0])].append(tile[1]['raw'] + ([tile[1]['entity_id']] if 'entity_id' in tile else []))

        output = [(l, layers[l]) for l in self.all_layers]
        return output

    def get_by_rect(self, rect):
        layers = self.get_visible((rect.x, rect.y), size_override=(rect.width, rect.height))
        tiles = []
        for layer in layers:
            for tile in layer[1]:
                tile_r = pygame.Rect(*tile[0], *(self.tile_size))
                if tile_r.colliderect(rect):
                    tiles.append(tile)

        return tiles
