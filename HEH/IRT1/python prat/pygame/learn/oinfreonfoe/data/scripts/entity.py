import math

import pygame

from .core_funcs import *

def collision_list(obj, obj_list):
    hit_list = []
    for r in obj_list:
        if obj.colliderect(r):
            hit_list.append(r)
    return hit_list

def silhouette(surf, color=(255, 255, 255)):
    mask = pygame.mask.from_surface(surf)
    new_surf = swap_color(mask.to_surface(), (255, 255, 255), color)
    new_surf.set_colorkey((0, 0, 0))
    return new_surf

def outline(target, src, pos, color):
    s = silhouette(src, color=color)
    for shift in [[0, 1], [1, 0], [-1, 0], [0, -1]]:
        target.blit(s, (pos[0] + shift[0], pos[1] + shift[1]))

class Entity:
    def __init__(self, assets, pos, size, type):
        self.assets = assets
        self.pos = list(pos).copy()
        self.size = list(size).copy()
        self.type = type
        self.flip = [False, False]
        self.rotation = 0
        self.centered = False
        self.opacity = 255
        self.scale = [1, 1]
        self.active_animation = None
        self.height = 0
        self.render_offset = [0, 0]
        self.flash = False

        if self.type + '_idle' in self.assets.animations:
            self.set_action('idle')

    @property
    def img(self):
        if not self.active_animation:
            img = self.current_image
        else:
            self.set_image(self.active_animation.img)
            img = self.current_image
        if self.scale != [1, 1]:
            img = pygame.transform.scale(img, (int(self.scale[0] * self.image_base_dimensions[0]), int(self.scale[1] * self.image_base_dimensions[1])))
        if any(self.flip):
            img = pygame.transform.flip(img, self.flip[0], self.flip[1])
        if self.rotation:
            img = pygame.transform.rotate(img, self.rotation)
        if self.opacity != 255:
            img.set_alpha(self.opacity)
        return img

    @property
    def rect(self):
        if self.type != 'player':
            if not self.centered:
                return pygame.Rect(self.pos[0] // 1, self.pos[1] // 1, self.size[0], self.size[1])
            else:
                return pygame.Rect((self.pos[0] - self.size[0] // 2) // 1, (self.pos[1] - self.size[1] // 2) // 1, self.size[0], self.size[1])
        else:
            if not self.centered:
                return pygame.Rect(self.pos[0] // 1, self.pos[1] // 1, self.size[0], self.size[1])
            else:
                return pygame.Rect((self.pos[0] - self.size[0] // 2) // 1, (self.pos[1] - self.size[1] // 2) // 1, 20, 25)

    @property
    def center(self):
        if self.centered:
            return self.pos.copy()
        else:
            return [self.pos[0] + self.size[0] // 2, self.pos[1] + self.size[1] // 2]

    def set_action(self, action_id, force=False):
        if force:
            self.active_animation = self.assets.new(self.type + '_' + action_id)
        elif (not self.active_animation) or (self.active_animation.data.id != self.type + '_' + action_id):
            self.active_animation = self.assets.new(self.type + '_' + action_id)

    def set_image(self, surf):
        self.current_image = surf.copy()
        self.image_base_dimensions = list(surf.get_size())

    def set_scale(self, new_scale, fit_hitbox=True):
        try:
            self.scale = new_scale.copy()
        except AttributeError:
            self.scale = [new_scale, new_scale]
        if fit_hitbox:
            self.size = [int(self.scale[0] * self.image_base_dimensions[0]), int(self.scale[1] * self.image_base_dimensions[1])]

    def get_angle(self, target):
        if isinstance(target, Entity):
            return math.atan2(target.center[1] - self.center[1], target.center[0] - self.center[0])
        else:
            return math.atan2(target[1] - self.center[1], target[0] - self.center[0])

    def get_render_angle(self, target):
        if isinstance(target, Entity):
            return math.atan2(target.center[1] - self.center[1], target.center[0] - self.center[0] - self.height)
        else:
            return math.atan2(target[1] - self.center[1], target[0] - self.center[0] - self.height)

    def get_distance(self, target):
        try:
            return math.sqrt((target.pos[0] - self.pos[0]) ** 2 + (target.pos[1] - self.pos[1]) ** 2)
        except:
            return math.sqrt((target[0] - self.pos[0]) ** 2 + (target[1] - self.pos[1]) ** 2)

    def in_range(self, target, range):
        return self.get_distance(target) <= range

    def get_visible(self):
        # TODO: implement for this project
        '''render_pos = ((self.pos[0] - offset[0]) // 1, (self.pos[1] - offset[1] - self.height) // 1)
        if not self.centered:
            render_r = pygame.Rect(*render_pos, *self.size)
        else:
            render_pos = [render_pos[0] - self.size[0], render_pos[1] - self.size[1]]
            render_r = pygame.Rect(*render_pos, *self.size)
        return self.game.camera.rect.colliderect(render_r)'''
        return True

    def move(self, motion, tiles):
        self.pos[0] += motion[0]
        hit_list = collision_list(self.rect, tiles)
        temp_rect = self.rect
        directions = {k : False for k in ['top', 'left', 'right', 'bottom']}
        for tile in hit_list:
            if motion[0] > 0:
                temp_rect.right = tile.left
                self.pos[0] = temp_rect.x
                directions['right'] = True
            if motion[0] < 0:
                temp_rect.left = tile.right
                self.pos[0] = temp_rect.x
                directions['left'] = True
            if self.centered:
                self.pos[0] += self.size[0] // 2
        self.pos[1] += motion[1]
        hit_list = collision_list(self.rect, tiles)
        temp_rect = self.rect
        for tile in hit_list:
            if motion[1] > 0:
                temp_rect.bottom = tile.top
                self.pos[1] = temp_rect.y
                directions['bottom'] = True
            if motion[1] < 0:
                temp_rect.top = tile.bottom
                self.pos[1] = temp_rect.y
                directions['top'] = True
            if self.centered:
                self.pos[1] += self.size[1] // 2
        return directions

    def render(self, surf, offset=(0, 0), alpha=255):
        offset = list(offset)
        if self.active_animation:
            offset[0] += self.active_animation.data.config['offset'][0]
            offset[1] += self.active_animation.data.config['offset'][1]
        if self.centered:
            offset[0] += self.img.get_width() // 2
            offset[1] += self.img.get_height() // 2
        img = self.img
        if (self.scale != [1, 1]) or (self.rotation != 0):
            x_diff = (self.current_image.get_width() - img.get_width()) // 2
            y_diff = (self.current_image.get_height() - img.get_height()) // 2
            offset[0] -= x_diff
            offset[1] -= y_diff * 2
        if self.active_animation and self.active_animation.data.config['outline']:
            outline(surf, img, ((self.pos[0] - offset[0]) // 1, (self.pos[1] - offset[1] - self.height) // 1), self.active_animation.data.config['outline'])
        if alpha != 255:
            img.set_alpha(alpha)
        surf.blit(img, ((self.pos[0] - offset[0] + self.render_offset[0]) // 1, (self.pos[1] - offset[1] - self.height + self.render_offset[1]) // 1))
        if self.flash:
            outline(surf, img, ((self.pos[0] - offset[0]) // 1, (self.pos[1] - offset[1] - self.height) // 1), (245, 237, 186))

    def update(self, dt):
        if self.active_animation:
            self.active_animation.play(dt)
