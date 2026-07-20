# Import necessary modules
from settings import *
from random import choice
from timer import Timer

# Define the Tooth class, which is a type of enemy in the game
class Tooth(pygame.sprite.Sprite):
    def __init__(self, pos, frames, groups, collision_sprites):
        # Initialize the sprite
        super().__init__(groups)
        # Set the frames for animation and the initial frame index
        self.frames, self.frame_index = frames, 0
        # Set the image for the sprite
        self.image = self.frames[self.frame_index]
        # Set the rectangle for the sprite
        self.rect = self.image.get_frect(topleft = pos)
        # Set the z-index for the sprite
        self.z = Z_LAYERS['main']

        # Set the direction for the sprite
        self.direction = choice((-1,1))
        # Set the collision rectangles for the sprite
        self.collision_rects = [sprite.rect for sprite in collision_sprites]
        # Set the speed for the sprite
        self.speed = 200

        # Set the timer for the sprite
        self.hit_timer = Timer(250)

    # Define the method to reverse the direction of the sprite
    def reverse(self):
        if not self.hit_timer.active:
            self.direction *= -1
            self.hit_timer.activate()

    # Define the update method for the sprite
    def update(self, dt):
        self.hit_timer.update()

        # Animate the sprite
        self.frame_index += ANIMATION_SPEED * dt
        self.image = self.frames[int(self.frame_index % len(self.frames))]
        self.image = pygame.transform.flip(self.image, True, False) if self.direction < 0 else self.image

        # Move the sprite
        self.rect.x += self.direction * self.speed * dt

        # Reverse the direction of the sprite
        floor_rect_right = pygame.FRect(self.rect.bottomright, (1,1))
        floor_rect_left = pygame.FRect(self.rect.bottomleft, (-1,1))
        wall_rect = pygame.FRect(self.rect.topleft + vector(-1,0), (self.rect.width + 2, 1))

        if floor_rect_right.collidelist(self.collision_rects) < 0 and self.direction > 0 or\
           floor_rect_left.collidelist(self.collision_rects) < 0 and self.direction < 0 or \
           wall_rect.collidelist(self.collision_rects) != -1:
            self.direction *= -1

# Define the Shell class, which is a type of enemy in the game
class Shell(pygame.sprite.Sprite):
    def __init__(self, pos, frames, groups, reverse, player, create_pearl):
        # Initialize the sprite
        super().__init__(groups)

        # Set the frames for animation
        if reverse:
            self.frames = {}
            for key, surfs in frames.items():
                self.frames[key] = [pygame.transform.flip(surf, True, False) for surf in surfs]
            self.bullet_direction = -1
        else:
            self.frames = frames
            self.bullet_direction = 1

        # Set the initial frame index and state
        self.frame_index = 0
        self.state = 'idle'
        # Set the image for the sprite
        self.image = self.frames[self.state][self.frame_index]
        # Set the rectangle for the sprite
        self.rect = self.image.get_frect(topleft = pos)
        self.old_rect = self.rect.copy()
        # Set the z-index for the sprite
        self.z = Z_LAYERS['main']
        # Set the player for the sprite
        self.player = player
        # Set the timer for the sprite
        self.shoot_timer = Timer(3000)
        self.has_fired = False
        self.create_pearl = create_pearl

    # Define the method to manage the state of the sprite
    def state_management(self):
        player_pos, shell_pos = vector(self.player.hitbox_rect.center), vector(self.rect.center)
        player_near = shell_pos.distance_to(player_pos) < 500
        player_front = shell_pos.x < player_pos.x if self.bullet_direction > 0 else shell_pos.x > player_pos.x
        player_level = abs(shell_pos.y - player_pos.y) < 30

        if player_near and player_front and player_level and not self.shoot_timer.active:
            self.state = 'fire'
            self.frame_index = 0
            self.shoot_timer.activate()

    # Define the update method for the sprite
    def update(self, dt):
        self.shoot_timer.update()
        self.state_management()

        # Animate the sprite and attack
        self.frame_index += ANIMATION_SPEED * dt
        if self.frame_index < len(self.frames[self.state]):
            self.image = self.frames[self.state][int(self.frame_index)]

            # Fire the sprite
            if self.state == 'fire' and int(self.frame_index) == 3 and not self.has_fired:
                self.create_pearl(self.rect.center, self.bullet_direction)
                self.has_fired = True

        else:
            self.frame_index = 0
            if self.state == 'fire':
                self.state = 'idle'
                self.has_fired = False

# Define the Pearl class, which is a type of enemy in the game
class Pearl(pygame.sprite.Sprite):
    def __init__(self, pos, groups, surf, direction, speed):
        self.pearl = True
        # Initialize the sprite
        super().__init__(groups)
        # Set the image for the sprite
        self.image = surf
        # Set the rectangle for the sprite
        self.rect = self.image.get_frect(center = pos + vector(50 * direction,0))
        # Set the direction and speed for the sprite
        self.direction = direction
        self.speed = speed
        # Set the z-index for the sprite
        self.z = Z_LAYERS['main']
        # Set the timers for the sprite
        self.timers = {'lifetime': Timer(5000), 'reverse': Timer(250)}

    # Define the method to reverse the direction of the sprite
    def reverse(self):
        if not self.timers['reverse'].active:
            self.direction *= -1
            self.timers['reverse'].activate()

    # Define the update method for the sprite
    def update(self, dt):
        for timer in self.timers.values():
            timer.update()

        self.rect.x += self.direction * self.speed * dt
        if not self.timers['lifetime'].active:
            self.kill()