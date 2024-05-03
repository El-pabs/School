# This was written as if it were a game jam game.
# The code is *mostly* thrown in one file for development efficiency.
# Read at your own risk.

import os
import sys
import math
import random
import time

import pygame
from pygame.locals import *

import data.scripts.tile_map as tile_map
import data.scripts.spritesheet_loader as spritesheet_loader
from data.scripts.gl_stuff import MGL
from data.scripts.foliage import AnimatedFoliage
from data.scripts.entity import Entity, outline
from data.scripts.anim_loader import AnimationManager
from data.scripts.grass import GrassManager
from data.scripts.text import Font
from data.scripts.particles import Particle, load_particle_images, particle_images
from data.scripts.core_funcs import normalize, swap_color
from data.scripts.config import foliage_data

TILE_SIZE = 16
MAX_LIGHTS = 16
MASK_SIZE = 128

pygame.init()
pygame.mixer.init()
pygame.display.set_caption('Hue Flowing')
screen = pygame.display.set_mode((640, 480), DOUBLEBUF | OPENGL |RESIZABLE)
display = pygame.Surface((320, 240), SRCALPHA)
ui_surf = display.copy()
clock = pygame.time.Clock()

load_particle_images('data/images/particles')
spritesheets, spritesheets_data = spritesheet_loader.load_spritesheets('data/images/spritesheets/')
foliage_animations = {}
for foliage_src in foliage_data:
    palette = foliage_data[foliage_src][0]
    motion_scale = foliage_data[foliage_src][1]
    foliage_animations[foliage_src] = AnimatedFoliage(spritesheets['foliage'][foliage_src[0]][foliage_src[1]].copy(), palette, motion_scale=motion_scale)

animation_manager = AnimationManager()

pygame.mixer.music.load('data/music.wav')
pygame.mixer.music.play(-1)
pygame.mixer.music.set_volume(0.6)

grass_sounds = [pygame.mixer.Sound('data/sfx/' + s + '.wav') for s in ['grass_0', 'grass_1', 'grass_2', 'grass_3', 'grass_4']]
grass_sounds_quiet = [pygame.mixer.Sound('data/sfx/' + s + '.wav') for s in ['grass_0', 'grass_1', 'grass_2', 'grass_3', 'grass_4']]
for sound in grass_sounds:
    sound.set_volume(0.3)
for sound in grass_sounds_quiet:
    sound.set_volume(0.15)
paint_sounds = [pygame.mixer.Sound('data/sfx/' + s + '.wav') for s in ['paint_0', 'paint_1']]
for sound in paint_sounds:
    sound.set_volume(0.2)
land_sound = pygame.mixer.Sound('data/sfx/land.wav')
jump_sound = pygame.mixer.Sound('data/sfx/jump.wav')
jump_sound.set_volume(0.5)
jump_boost_sound = pygame.mixer.Sound('data/sfx/jump_boost.wav')
slide_sounds = [pygame.mixer.Sound('data/sfx/' + s + '.wav') for s in ['slide', 'slide_2']]
for sound in slide_sounds:
    sound.set_volume(0.7)
death_sound = pygame.mixer.Sound('data/sfx/death.wav')

def load_img(path):
    img = pygame.image.load(path).convert()
    img.set_colorkey((0, 0, 0))
    return img

class Player(Entity):
    def __init__(self, *args):
        super().__init__(*args)
        self.movement_velocity = [0, 0]
        self.natural_velocity = [0, 0]
        self.air_timer = 0
        self.wall_timer = 0
        self.spinning = 0
        self.wall_slide = 0
        self.max_jumps = 2
        self.jumps = self.max_jumps
        self.last_safe = tuple(self.pos)
        self.last_safe_scroll = tuple(gd.scroll)
        self.just_died = 0
        self.last_input = 0

    def update(self, gd):
        super().update(1 / 60)

        self.just_died = max(0, self.just_died - 1)

        self.air_timer += 1
        self.wall_timer += 1

        self.scale[1] += (1 - self.scale[1]) / 3.5
        if self.scale[1] > 0.95:
            self.scale[1] = 1

        current_input = gd.user_input['right'] - gd.user_input['left']
        if current_input != self.last_input:
            if self.movement_velocity[1] >= 0:
                if current_input > 0:
                    gd.animations.append(Entity(animation_manager, (self.center[0] + 4, self.pos[1] + self.rect.height), (2, 2), 'turnanim'))
                if current_input < 0:
                    gd.animations.append(Entity(animation_manager, (self.center[0] - 4, self.pos[1] + self.rect.height), (2, 2), 'turnanim'))
                    gd.animations[-1].flip[0] = True
        self.last_input = current_input

        self.movement_velocity[1] = min(3, self.movement_velocity[1] + 0.15)

        self.movement_velocity[0] = normalize(self.movement_velocity[0], 0.15)
        self.natural_velocity[0] = normalize(self.natural_velocity[0], 0.07)
        if self.natural_velocity[0] >= 0:
            if gd.user_input['right']:
                self.movement_velocity[0] = min(2, self.movement_velocity[0] + 0.35)
                self.flip[0] = False
        if self.natural_velocity[0] <= 0:
            if gd.user_input['left']:
                self.movement_velocity[0] = max(-2, self.movement_velocity[0] - 0.35)
                self.flip[0] = True
        if gd.user_input['jump']:
            if not self.wall_slide:
                if self.jumps:
                    jump_sound.play()
                    gd.animations.append(Entity(animation_manager, (self.center[0], self.pos[1] + self.rect.height), (2, 2), 'jumpanim'))
                    self.movement_velocity[1] = -3.55
                    self.jumps -= 1
            else:
                jump_sound.play()
                self.movement_velocity[1] = -3
                self.natural_velocity[0] = self.wall_slide * -2.5
                for i in range(10):
                    angle = random.random() * math.pi * 0.5 - math.pi * 0.25
                    if self.wall_slide == 1:
                        angle += math.pi
                    force = random.random() * 40 + 10
                    gd.leaves.append(Particle(*list(self.center), 'p', [math.cos(angle) * force, math.sin(angle) * force], 2.5 + random.random() * 1.5, random.random() * 2 + 3, custom_color=(22, 22, 39)))
                if self.wall_slide == 1:
                    gd.animations.append(Entity(animation_manager, (self.pos[0], self.center[1]), (2, 2), 'jumpanim2'))
                    gd.animations[-1].flip[0] = True
                    self.flip[0] = True
                else:
                    gd.animations.append(Entity(animation_manager, (self.pos[0], self.center[1]), (2, 2), 'jumpanim2'))
                    self.flip[0] = False
                self.movement_velocity[0] = 0
            if (self.air_timer > 4) or (self.wall_slide):
                if self.flip[0]:
                    self.spinning = 1
                else:
                    self.spinning = -1
            self.wall_slide = 0
            random.choice(paint_sounds).play()
            for i in range(3):
                gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() * math.pi * 2, random.random() * 3 + 2, phase=random.random() * 2, alpha_shift=random.random() / 2))

        if self.spinning:
            if random.random() < 0.3:
                angle = random.random() * math.pi * 2
                force = random.random() * 50 + 50
                gd.leaves.append(Particle(*list(self.center), 'p', [math.cos(angle) * force, math.sin(angle) * force], 3.5 + random.random() * 4.5, random.random() * 2 + 3.5, custom_color=(22, 22, 39)))
            if random.random() < 0.2:
                if random.random() < 0.25:
                    random.choice(paint_sounds).play()
                gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() * math.pi * 2, random.random() * 3 + 2, phase=random.random() * 2, alpha_shift=random.random() / 2, decay_rate=0.35))
            if random.random() < 0.02:
                random.choice(paint_sounds).play()
                gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() * math.pi * 2, random.random() * 3 + 1, phase=random.random() * 1, alpha_shift=random.random() / 2, decay_rate=0.15))

        self.rotation += self.spinning * 16

        if self.wall_timer > 4:
            self.wall_slide = 0
            if self.air_timer > 4:
                self.set_action('jump')
            elif self.movement_velocity[0] != 0:
                self.set_action('run')
            else:
                self.set_action('idle')
        else:
            self.set_action('slide')
            if random.random() < 0.06:
                random.choice(slide_sounds).play()

        frame_motion = [self.movement_velocity[0] + self.natural_velocity[0], self.movement_velocity[1] + self.natural_velocity[1]]
        start_pos = self.pos.copy()
        rects = [t[1] for t in gd.level_map.get_nearby_rects(self.center)]
        collisions = self.move(frame_motion, rects)
        end_pos = self.pos.copy()
        pos_change = (end_pos[0] - start_pos[0], end_pos[1] - start_pos[1])
        if self.air_timer < 5:
            if self.movement_velocity[0]:
                if random.random() < 0.1:
                    gd.leaves.append(Particle(self.center[0], self.pos[1] + self.rect.height, 'grass', [random.random() * 10 + self.movement_velocity[0] * 8, -8 - random.random() * 4], 0.7 + random.random() * 0.6, random.random() * 2, custom_color=random.choice([(26, 53, 47), (47, 99, 39), (89, 147, 38), (187, 215, 28), (243, 242, 188)])))
                if random.random() < 0.05:
                    random.choice(grass_sounds).play()
            if random.random() < 0.2:
                if pos_change[0] > 0:
                    gd.paint_blobs.append(PaintBlob([gd.player.center[0], gd.player.pos[1] + random.random() * gd.player.rect.height + 4], random.random() - 0.5 - math.pi * 0.3, random.random() * 0.5 + 0.5, phase=random.random() * 2 + 1.5, alpha_shift=random.random() / 2, decay_rate=0.05, spawn_delay=1, swerve_rate=0.2))
                if pos_change[0] < 0:
                    gd.paint_blobs.append(PaintBlob([gd.player.center[0], gd.player.pos[1] + random.random() * gd.player.rect.height + 4], random.random() - 0.5 - math.pi * 0.7, random.random() * 0.5 + 0.5, phase=random.random() * 2 + 1.5, alpha_shift=random.random() / 2, decay_rate=0.05, spawn_delay=1, swerve_rate=0.2))
        if collisions['bottom'] or collisions['top']:
            self.movement_velocity[1] = 0
        if collisions['left'] or collisions['right']:
            if self.air_timer > 4:
                self.movement_velocity[1] = min(0.2, self.movement_velocity[1])
                self.movement_velocity[0] = 0
                self.spinning = 0
                self.rotation = 0
                self.wall_timer = 0
                if frame_motion[0] > 0:
                    self.wall_slide = 1
                    if random.random() < 0.5:
                        gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() - 0.5 - math.pi * 0.7, random.random() * 3, phase=random.random() * 2 + 1.5, alpha_shift=random.random() / 2, decay_rate=0.15))
                if frame_motion[0] < 0:
                    self.wall_slide = -1
                    if random.random() < 0.5:
                        gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() - 0.5 - math.pi * 0.3, random.random() * 3, phase=random.random() * 2 + 1.5, alpha_shift=random.random() / 2, decay_rate=0.15))

        if collisions['bottom']:
            if frame_motion[1] > 2:
                land_sound.play()
                random.choice(grass_sounds).play()
                self.scale[1] = 0.2
                gd.animations.append(Entity(animation_manager, (self.center[0], self.pos[1] + self.rect.height), (2, 2), 'landanim'))
                random.choice(paint_sounds).play()
                for i in range(8):
                    gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() - 0.5 - math.pi * 0.5, random.random() + frame_motion[1] * 1.5, phase=random.random() * 2, alpha_shift=random.random() / 2, decay_rate=0.25, swerve_rate=0.4))
                for i in range(4):
                    gd.paint_blobs.append(PaintBlob(gd.player.center, random.random() * math.pi * 2, random.random() + frame_motion[1] - 1, phase=random.random() * 2, alpha_shift=random.random() / 2, decay_rate=0.35, swerve_rate=0.4))
            self.air_timer = 0
            self.spinning = 0
            self.rotation = 0
            self.jumps = self.max_jumps
            self.last_safe = (self.pos[0], self.pos[1] - 1)
            self.last_safe_scroll = tuple(gd.scroll)

        if self.rect.right > gd.rscroll[0] + display.get_width():
            self.pos[0] = gd.rscroll[0] + display.get_width() - self.rect.width

        if self.rect.left < gd.rscroll[0]:
            self.pos[0] = gd.rscroll[0]

        if self.rect.top < gd.rscroll[1]:
            self.pos[1] = gd.rscroll[1]

        if self.pos[1] > gd.rscroll[1] + display.get_height() + 16 * 3:
            self.pos = [self.last_safe[0], self.last_safe[1] - 2]
            gd.scroll = list(self.last_safe_scroll)
            self.just_died = 50
            death_sound.play()

    def render(self, *args, **kwargs):
        if (not self.just_died) or (random.random() < 0.7):
            super().render(*args, **kwargs)

class PaintBlob:
    def __init__(self, pos, angle, force, phase=0, alpha_shift=0, decay_rate=0.5, swerve_rate=1.0, spawn_delay=0):
        self.pos = list(pos)
        self.velocity = [math.cos(angle) * force, math.sin(angle) * force]
        self.phase = phase
        self.alpha_shift = alpha_shift
        self.decay_rate = decay_rate
        self.swerve = random.random() * swerve_rate
        self.color = random.choice([(255, 255, 255), (255, 128, 128), (128, 255, 128), (128, 128, 255)])
        self.spawn_delay = spawn_delay
        self.drip = bool(spawn_delay)
        self.branch = False

    def spawn_child(self, drip=False):
        if not drip:
            if not self.branch:
                angle = math.atan2(self.velocity[1], self.velocity[0])
                force = math.sqrt(self.velocity[0] ** 2 + self.velocity[1] ** 2)
                new_pb = PaintBlob(self.pos, angle + random.random() * 2 - 1, force * (random.random() * 0.2 + 0.8), self.phase, self.alpha_shift, self.decay_rate, swerve_rate=1.0)
                new_pb.branch = True
                gd.paint_blobs.append(new_pb)
        elif self.alpha_shift < 0.25:
            angle = math.pi * 0.5
            force = 0.2
            new_pb = PaintBlob(self.pos, angle, force, self.phase, self.alpha_shift, 0.05, swerve_rate=0.25, spawn_delay=random.random() * 240)
            gd.paint_blobs.append(new_pb)

    def update(self, gd):
        self.spawn_delay = max(0, self.spawn_delay - 1)
        if not self.spawn_delay:
            self.velocity[0] = normalize(self.velocity[0], 0.02)
            speed = math.sqrt(self.velocity[0] ** 2 + self.velocity[1] ** 2)
            self.velocity[0] += math.sin(time.time() * 100 / speed + self.swerve * 1000) * self.swerve * 0.3
            self.velocity[1] += math.sin(time.time() * 120 / speed + self.swerve * 1200) * self.swerve * 0.3
            if self.drip:
                self.velocity[1] = min(0.4, self.velocity[1] + 0.15)
            else:
                self.velocity[1] = min(2.5, self.velocity[1] + 0.25)
            self.phase += self.decay_rate
            if self.phase >= len(particle_images['p']):
                return False

            if not self.drip:
                if (self.phase > 5) and (random.random() < 0.6):
                    self.spawn_child(drip=True)
                if (self.phase < 4) and (random.random() < 0.05):
                    self.spawn_child()

            # make sure we get full coverage during fast movement
            magnitude = math.ceil(math.sqrt(self.velocity[0] ** 2 + self.velocity[1] ** 2))
            for i in range(magnitude):
                self.pos[0] += self.velocity[0] / magnitude
                self.pos[1] += self.velocity[1] / magnitude
                self.render(gd)

        return True

    def render(self, gd):
        phase_progress = min(1, 1 - (self.phase - len(particle_images['p']) * 0.5) / len(particle_images['p']) * 2)
        phase_progress = max(0, phase_progress - self.alpha_shift)
        color = (255 * phase_progress, 255 * phase_progress, 255 * phase_progress)
        img = swap_color(particle_images['p'][int(self.phase)].copy(), (255, 255, 255), color)
        render_pos = (self.pos[0] - img.get_width() // 2, self.pos[1] - img.get_height() // 2)
        gd.mark_world_mask(img, render_pos)

class GameData():
    def __init__(self):
        self.reset()

    def frame_reset(self):
        self.rendered_entities = False
        self.global_time = time.time()

    def reset(self):
        self.frame_reset()
        self.level_map = None
        self.scroll = [0, 0]
        self.spawn = [0, 0]
        self.player = None
        self.user_input = {
            'right': False,
            'left': False,
            'jump': False,
        }
        self.gm = GrassManager('data/images/grass', tile_size=16)
        self.leaves = []
        self.lights = []
        self.camera_blocks = {'left': [], 'right': [], 'up': [], 'down': []}
        self.world_masks = {}
        self.paint_blobs = []
        self.upgrades = []
        self.pillar = Entity(animation_manager, (0, 0), (14, 61), 'pillar')
        self.ending_state = 0
        self.tutorial = True
        self.animations = []

    def get_world_mask(self):
        tl = (self.rscroll[0] // MASK_SIZE, self.rscroll[1] // MASK_SIZE)
        br = ((self.rscroll[0] + display.get_width()) // MASK_SIZE, (self.rscroll[1] + display.get_height()) // MASK_SIZE)
        display_mask = pygame.Surface(display.get_size())
        for y in range(br[1] - tl[1] + 1):
            for x in range(br[0] - tl[0] + 1):
                mask_loc = (tl[0] + x, tl[1] + y)
                if mask_loc not in self.world_masks:
                    self.world_masks[mask_loc] = pygame.Surface((MASK_SIZE, MASK_SIZE))
                display_mask.blit(self.world_masks[mask_loc], (mask_loc[0] * MASK_SIZE - self.rscroll[0], mask_loc[1] * MASK_SIZE - self.rscroll[1]))
        return display_mask

    def mask_at(self, pos):
        mask_loc = (pos[0] // MASK_SIZE, pos[1] // MASK_SIZE)
        if mask_loc not in self.world_masks:
            self.world_masks[mask_loc] = pygame.Surface((MASK_SIZE, MASK_SIZE))
        return (mask_loc, self.world_masks[mask_loc])

    def mark_world_mask(self, surface, pos):
        corners = [
            (pos[0], pos[1]),
            (pos[0] + surface.get_width(), pos[1]),
            (pos[0], pos[1] + surface.get_height()),
            (pos[0] + surface.get_width(), pos[1] + surface.get_height()),
        ]
        collided_corners = set([self.mask_at(corner) for corner in corners])
        for mask_data in collided_corners:
            loc = mask_data[0]
            mask = mask_data[1]
            mask.blit(surface, (pos[0] - loc[0] * MASK_SIZE, pos[1] - loc[1] * MASK_SIZE), special_flags=BLEND_RGB_MAX)

    @property
    def rscroll(self):
        return (int(self.scroll[0]), int(self.scroll[1]))

    def load_map(self, path):
        self.level_map = tile_map.TileMap((TILE_SIZE, TILE_SIZE), display.get_size())
        self.level_map.load_map('data/levels/' + path + '.json')
        self.camera_blocks = {'left': [], 'right': [], 'up': [], 'down': []}
        self.lights = []

        for entity in self.level_map.load_entities():
            entity_type = entity[2]['type'][1]
            if entity_type == 0:
                self.spawn = entity[2]['raw'][0]
            if entity_type == 1:
                self.upgrades.append(Entity(animation_manager, (entity[2]['raw'][0][0], entity[2]['raw'][0][1]), (13, 19), 'jump_upgrade'))
            elif entity_type == 9:
                self.pillar.pos = [entity[2]['raw'][0][0], entity[2]['raw'][0][1]]
            elif entity_type > 5:
                light_strength = entity_type - 5
                self.lights.append([entity[2]['raw'][0][0], entity[2]['raw'][0][1], light_strength])
            elif entity_type > 1:
                block_map = {2: 'right', 3: 'left', 4: 'down', 5: 'up'}
                self.camera_blocks[block_map[entity_type]].append(pygame.Rect(entity[2]['raw'][0][0], entity[2]['raw'][0][1], 16, 16))

        self.scroll = [self.spawn[0] - display.get_width() // 2, self.spawn[1] - display.get_height() // 2]
        self.player = Player(animation_manager, (self.spawn[0], self.spawn[1]), (11, 16), 'player')

        self.level_map.load_grass(self.gm)

jump_img = load_img('data/images/misc/jump_icon.png')
tutorial_img = load_img('data/images/misc/tutorial.png')
player_base_paint = load_img('data/images/misc/player_base_paint.png')
jump_icon_scales = []

gd = GameData()
gd.load_map('main')

mgl = MGL()

while True:
    gd.frame_reset()

    display.fill((0, 0, 0, 0))
    ui_surf.fill((0, 0, 0, 0))

    if random.random() < 0.005:
        random.choice(grass_sounds_quiet).play()

    gd.ending_state = min(1, max(0, -gd.scroll[1] - 280) / 160)
    if gd.ending_state == 1:
        break

    gd.scroll[0] += (gd.player.center[0] - display.get_width() // 2 - gd.scroll[0]) / 20
    view_r = pygame.Rect(gd.scroll[0], gd.scroll[1], display.get_width(), display.get_height())

    for direction in ['left', 'right']:
        for block in gd.camera_blocks[direction]:
            if block.colliderect(view_r):
                if direction == 'right':
                    view_r.left = block.right
                if direction == 'left':
                    view_r.right = block.left
                gd.scroll[0] = view_r.x
                gd.scroll[1] = view_r.y

    gd.scroll[1] += (gd.player.center[1] - display.get_height() // 2 - gd.scroll[1]) / 20
    view_r = pygame.Rect(gd.scroll[0], gd.scroll[1], display.get_width(), display.get_height())

    for direction in ['up', 'down']:
        for block in gd.camera_blocks[direction]:
            if block.colliderect(view_r):
                if direction == 'up':
                    view_r.bottom = block.top
                if direction == 'down':
                    view_r.top = block.bottom
                gd.scroll[0] = view_r.x
                gd.scroll[1] = view_r.y

    view_r = pygame.Rect(gd.scroll[0], gd.scroll[1], display.get_width(), display.get_height())

    visible_lights = []
    for light in gd.lights:
        light_r = pygame.Rect(light[0], light[1], (3 + light[2]) * 16 * 3, 16 * 26)
        if light_r.colliderect(view_r):
            visible_lights.append(((light[0] - gd.rscroll[0]) / display.get_width(), (light[1] - gd.rscroll[1]) / display.get_height(), light[2]))
    # pad lights with null
    while len(visible_lights) < MAX_LIGHTS:
        visible_lights.append((0, 0, -1))

    gd.gm.apply_force(gd.player.center, 5, 6)

    render_list = gd.level_map.get_visible(gd.rscroll)
    for layer in render_list:
        layer_id = layer[0]
        if not gd.rendered_entities:
            if layer_id >= -3:
                gd.rendered_entities = True

                for anim in gd.animations.copy():
                    anim.update(1 / 60)
                    anim.render(display, gd.scroll)
                    finished = anim.active_animation.frame >= anim.active_animation.data.duration
                    if finished:
                        gd.animations.remove(anim)

                for upgrade in gd.upgrades.copy():
                    upgrade.update(1 / 60)
                    if random.random() < 0.1:
                        angle = math.pi / 2
                        force = 20
                        gd.leaves.append(Particle(upgrade.pos[0] + upgrade.rect.width * random.random(), upgrade.pos[1] + upgrade.rect.height, 'p', [math.cos(angle) * force, math.sin(angle) * force], 1.5 + random.random() * 1.5, random.random() * 2 + 4, custom_color=(22, 22, 39)))
                    upgrade.render(display, gd.scroll)
                    if upgrade.rect.colliderect(gd.player.rect):
                        gd.player.max_jumps += 1
                        gd.upgrades.remove(upgrade)
                        jump_boost_sound.play()
                        for i in range(40):
                            angle = random.random() * math.pi * 2
                            force = random.random() * 70
                            gd.leaves.append(Particle(upgrade.pos[0] + upgrade.rect.width * random.random(), upgrade.pos[1] + upgrade.rect.height, 'p', [math.cos(angle) * force, math.sin(angle) * force], 0.5 + random.random() * 0.5, random.random() * 2 + 4, custom_color=(22, 22, 39)))
                    if upgrade.rect.colliderect(view_r):
                        if random.random() < 0.05:
                            angle = math.pi * 0.5 + random.random() - 0.5
                            force = 1
                            new_pb = PaintBlob((upgrade.center[0], upgrade.pos[1]), angle, force, random.random() * 2, 0, 0.04, swerve_rate=0.35, spawn_delay=random.random() * 240)
                            gd.paint_blobs.append(new_pb)

                if gd.pillar.rect.colliderect(view_r):
                    gd.pillar.render(display, gd.rscroll)
                    gd.pillar.active_animation.frame = gd.player.max_jumps - 2
                    gd.pillar.active_animation.calc_img()
                    if random.random() < 0.03:
                        angle = -math.pi / 2
                        force = 20
                        gd.leaves.append(Particle(gd.pillar.pos[0] + gd.pillar.rect.width * random.random(), gd.pillar.pos[1] + gd.pillar.rect.height, 'p', [math.cos(angle) * force, math.sin(angle) * force], 0.5 + random.random() * 0.5, random.random() * 2 + 4, custom_color=(22, 22, 39)))
                    if random.random() < 0.05:
                        angle = math.pi * 0.5 + random.random() - 0.5
                        force = 1
                        new_pb = PaintBlob((gd.pillar.center[0], gd.pillar.pos[1]), angle, force, random.random() * 2, 0, 0.04, swerve_rate=0.35, spawn_delay=random.random() * 240)
                        gd.paint_blobs.append(new_pb)

                gd.player.render(display, gd.rscroll)

                gd.gm.update_render(display, 1 / 60, offset=gd.rscroll, rot_function=lambda x, y: int((math.sin(x / 100 + gd.global_time * 1.5) - 0.7) * 30) / 10)

        for tile in layer[1]:
            if tile[1][0] == 'foliage':
                seed = int(tile[0][1] * tile[0][0] + (tile[0][0] + 10000000) ** 1.2)
                spritesheet_pos = (tile[1][1], tile[1][2])
                f_anim = foliage_animations[spritesheet_pos]
                f_anim.render(display, (tile[0][0] - gd.rscroll[0], tile[0][1] - gd.rscroll[1]), m_clock=gd.global_time / 2, seed=seed)
                chance = 0.003
                if tile[1][1] > 2:
                    chance = 0.02
                if random.random() < chance:
                    pos = f_anim.find_leaf_point()
                    color_set = foliage_data[spritesheet_pos][0][1:]
                    spawn_pos = (tile[0][0] + pos[0], tile[0][1] + pos[1])
                    if not gd.level_map.tile_collide(spawn_pos):
                        gd.leaves.append(Particle(*spawn_pos, 'grass', [random.random() * 10 + 10, 8 + random.random() * 4], 0.7 + random.random() * 0.6, random.random() * 2, custom_color=random.choice(color_set)))
            else:
                offset = [0, 0]
                if tile[1][0] in spritesheets_data:
                    tile_id = str(tile[1][1]) + ';' + str(tile[1][2])
                    if tile_id in spritesheets_data[tile[1][0]]:
                        if 'tile_offset' in spritesheets_data[tile[1][0]][tile_id]:
                            offset = spritesheets_data[tile[1][0]][tile_id]['tile_offset']
                img = spritesheet_loader.get_img(spritesheets, tile[1])
                display.blit(img, (tile[0][0] - gd.rscroll[0] + offset[0], tile[0][1] - gd.rscroll[1] + offset[1]))

    gd.player.update(gd)
    gd.mark_world_mask(player_base_paint, (gd.player.center[0] - player_base_paint.get_width() // 2, gd.player.center[1] - player_base_paint.get_height() // 2))
    if random.random() < 0.2:
        angle = math.pi * 0.5
        force = 0.2
        new_pb = PaintBlob(gd.player.center, angle, force, 4, 0.3, 0.015, swerve_rate=0.45, spawn_delay=random.random() * 240)
        gd.paint_blobs.append(new_pb)

    for blob in gd.paint_blobs.copy():
        alive = blob.update(gd)
        if not alive:
            gd.paint_blobs.remove(blob)

    # ended up being particles + leaves
    for particle in gd.leaves.copy():
        alive = particle.update(1 / 60)
        if particle.type == 'grass':
            shift = math.sin(particle.x / 20 + gd.global_time * 1.5) * 16
            shift *= min(1, particle.time_alive)
            particle.draw(display, (gd.rscroll[0] + shift, gd.rscroll[1]))
        else:
            particle.draw(display, (gd.rscroll[0], gd.rscroll[1]))
        if not alive:
            gd.leaves.remove(particle)

    gd.user_input['jump'] = False
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sys.exit()
        if event.type == VIDEORESIZE:
            if (event.w / event.h) < 4 / 3:
                new_size = (event.w, event.w * 0.75)
                screen = pygame.display.set_mode(new_size, DOUBLEBUF | OPENGL |RESIZABLE)
        if event.type == KEYDOWN:
            if event.key == K_ESCAPE:
                pygame.quit()
                sys.exit()
            if event.key == K_RIGHT:
                gd.user_input['right'] = True
                gd.tutorial = False
            if event.key == K_LEFT:
                gd.user_input['left'] = True
                gd.tutorial = False
            if event.key == K_UP:
                gd.user_input['jump'] = True
                gd.tutorial = False
        if event.type == KEYUP:
            if event.key == K_RIGHT:
                gd.user_input['right'] = False
            if event.key == K_LEFT:
                gd.user_input['left'] = False

    for i in range(gd.player.max_jumps):
        if i >= len(jump_icon_scales):
            jump_icon_scales.append(0)
        if i >= gd.player.jumps:
            jump_icon_scales[i] += -jump_icon_scales[i] * 0.3
            if jump_icon_scales[i] < 0.01:
                jump_icon_scales[i] = 0
        else:
            jump_icon_scales[i] += (1 - jump_icon_scales[i]) * 0.3
            if jump_icon_scales[i] > 0.99:
                jump_icon_scales[i] = 1
        scale = jump_icon_scales[i]
        jump_img_scaled = pygame.transform.scale(jump_img, (jump_img.get_width() * scale, jump_img.get_height() * scale))
        offset = ((jump_img.get_width() - jump_img_scaled.get_width()) // 2, (jump_img.get_height() - jump_img_scaled.get_height()) // 2)
        ui_surf.blit(jump_img_scaled, (5 + offset[0], 5 + i * 15 + offset[1]))

    if gd.tutorial:
        offset = 0 if time.time() % 1 < 0.7 else 1
        ui_surf.blit(tutorial_img, (gd.player.center[0] - gd.rscroll[0] - tutorial_img.get_width() // 2, gd.player.pos[1] - gd.rscroll[1] - 30 + offset))

    world_mask = gd.get_world_mask()
    mgl.pg2tx(world_mask, 'world_mask')
    mgl.pg2tx(display, 'base_display')
    mgl.pg2tx(ui_surf, 'ui_surf')
    mgl.render(gd.rscroll, visible_lights, gd.ending_state)
    pygame.display.flip()
    clock.tick(65)

# ending
while True:
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sys.exit()
        if event.type == VIDEORESIZE:
            if (event.w / event.h) < 4 / 3:
                new_size = (event.w, event.w * 0.75)
                screen = pygame.display.set_mode(new_size, DOUBLEBUF | OPENGL |RESIZABLE)
        if event.type == KEYDOWN:
            if event.key == K_ESCAPE:
                pygame.quit()
                sys.exit()

    mgl.render(gd.rscroll, visible_lights, gd.ending_state)
    pygame.display.flip()
    clock.tick(65)
