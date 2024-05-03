import os
import random

import pygame

global e_colorkey
e_colorkey = (0, 0, 0)
global particle_images
particle_images = {}

def circle_surf(size, color):
    surf = pygame.Surface((size * 2 + 2, size * 2 + 2))
    pygame.draw.circle(surf, color, (size + 1, size + 1), size)
    return surf

def blit_center(target_surf, surf, loc):
    target_surf.blit(surf, (loc[0] - surf.get_width() // 2, loc[1] - surf.get_height() // 2))

def blit_center_add(target_surf, surf, loc):
    target_surf.blit(surf, (loc[0] - surf.get_width() // 2, loc[1] - surf.get_height() // 2), special_flags=pygame.BLEND_RGBA_ADD)

def particle_file_sort(l):
    l2 = []
    for obj in l:
        l2.append(int(obj[:-4]))
    l2.sort()
    l3 = []
    for obj in l2:
        l3.append(str(obj) + '.png')
    return l3

def load_particle_images(path):
    global particle_images, e_colorkey
    file_list = os.listdir(path)
    for folder in file_list:
        #try:
        img_list = os.listdir(path + '/' + folder)
        img_list = particle_file_sort(img_list)
        images = []
        for img in img_list:
            images.append(pygame.image.load(path + '/' + folder + '/' + img).convert())
        for img in images:
            img.set_colorkey(e_colorkey)
        particle_images[folder] = images.copy()
        #except:
        #    pass

class Particle(object):

    def __init__(self, x, y, particle_type, motion, decay_rate, start_frame, custom_color=None, physics=False):
        self.x = x
        self.y = y
        self.type = particle_type
        self.motion = motion
        self.decay_rate = decay_rate
        self.color = custom_color
        self.frame = start_frame
        self.physics = physics
        self.orig_motion = self.motion
        self.temp_motion = [0, 0]
        self.time_left = len(particle_images[self.type]) + 1 - self.frame
        self.render = True
        self.random_constant = random.randint(20, 30) / 30
        self.time_alive = 0

    def draw(self, surface, scroll):
        global particle_images
        if self.render:
            #if self.frame > len(particle_images[self.type]):
            #    self.frame = len(particle_images[self.type])
            if self.color == None:
                blit_center(surface,particle_images[self.type][int(self.frame)],(self.x-scroll[0],self.y-scroll[1]))
            else:
                blit_center(surface,swap_color(particle_images[self.type][int(self.frame)],(255,255,255),self.color),(self.x-scroll[0],self.y-scroll[1]))

    def update(self, dt):
        self.time_alive += dt
        self.frame += self.decay_rate * dt
        self.time_left = len(particle_images[self.type]) + 1 - self.frame
        running = True
        self.render = True
        if self.frame >= len(particle_images[self.type]):
            self.render = False
            if self.frame >= len(particle_images[self.type]) + 1:
                running = False
            running = False
        if not self.physics:
            self.x += (self.temp_motion[0] + self.motion[0]) * dt
            self.y += (self.temp_motion[1] + self.motion[1]) * dt
            if self.type == 'p2':
                self.motion[1] += dt * 140
        self.temp_motion = [0, 0]
        return running


# other useful functions

def swap_color(img,old_c,new_c):
    global e_colorkey
    img.set_colorkey(old_c)
    surf = img.copy()
    surf.fill(new_c)
    surf.blit(img,(0,0))
    surf.set_colorkey(e_colorkey)
    return surf
