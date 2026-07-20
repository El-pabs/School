import os, json

import pygame

from .core_funcs import *

ANIMATION_PATH = 'data/images/animations'
COLORKEY = (0, 0, 0)

def load_img(path, colorkey):
    img = pygame.image.load(path).convert()
    img.set_colorkey(colorkey)
    return img

class AnimationData:
    def __init__(self, path, colorkey=None):
        self.id = path.split('/')[-1]
        self.image_list = []
        for img in os.listdir(path):
            if img.split('.')[-1] == 'png':
                self.image_list.append([int(img.split('.')[0].split('_')[-1]), load_img(path + '/' + img, colorkey)])
        try:
            f = open(path + '/config.json', 'r')
            self.config = json.loads(f.read())
            f.close()
        except FileNotFoundError:
            self.config = {
                'frames': [5 for i in range(len(self.image_list))],
                'loop': True,
                'speed': 1.0,
                'centered': False,
                'paused': False,
                'outline': None,
                'offset': [0, 0],
            }
            f = open(path + '/config.json', 'w')
            f.write(json.dumps(self.config))
            f.close()
        self.image_list.sort()
        self.image_list = [v[1] for v in self.image_list]
        self.frame_surfs = []
        total = 0
        for i, frame in enumerate(self.config['frames']):
            total += frame
            self.frame_surfs.append([total, self.image_list[i]])

    @property
    def duration(self):
        return sum(self.config['frames'])

class Animation:
    def __init__(self, animation_data):
        self.data = animation_data
        self.frame = 0
        self.paused = self.data.config['paused']
        self.calc_img()
        self.rotation = 0
        self.just_looped = False

    def render(self, surf, pos, offset=(0, 0)):
        img = self.img
        rot_offset = [0, 0]
        if self.rotation:
            orig_size = self.img.get_size()
            img = pygame.transform.rotate(self.img, self.rotation)
            if not self.data.config['centered']:
                rot_offset = [(img.get_width() - orig_size[0]) // 2, (img.get_height() - orig_size[1]) // 2]
        if self.data.config['outline']:
            outline(surf, img, (pos[0] - offset[0] - img.get_width() // 2, pos[1] - offset[1] - img.get_height() // 2))
        if self.data.config['centered']:
            surf.blit(img, (pos[0] - offset[0] - img.get_width() // 2, pos[1] - offset[1] - img.get_height() // 2))
        else:
            surf.blit(img, (pos[0] - offset[0] + rot_offset[0], pos[1] - offset[1] + rot_offset[1]))

    def calc_img(self):
        for frame in self.data.frame_surfs:
            if frame[0] > self.frame:
                self.img = frame[1]
                break
        if self.data.frame_surfs[-1][0] < self.frame:
            self.img = self.data.frame_surfs[-1][1]

    def play(self, dt):
        self.just_looped = False
        if not self.paused:
            self.frame += dt * 60 * self.data.config['speed']
        if self.data.config['loop']:
            while self.frame > self.data.duration:
                self.frame -= self.data.duration
                self.just_looped = True
        self.calc_img()

    def rewind(self):
        self.frame = 0

    def set_speed(self, speed):
        self.data.config['speed'] = speed

    def set_frame_index(self, index):
        self.frame = self.data.frame_surfs[index][0]

    def pause(self):
        self.paused = True

    def unpause(self):
        self.paused = False

class AnimationManager:
    def __init__(self):
        self.animations = {}
        for anim in os.listdir(ANIMATION_PATH):
            self.animations[anim] = AnimationData(ANIMATION_PATH + '/' + anim, COLORKEY)

    def new(self, anim_id):
        return Animation(self.animations[anim_id])
