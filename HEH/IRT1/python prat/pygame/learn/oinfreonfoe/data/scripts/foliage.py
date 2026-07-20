import math
import random

import pygame

def extract_color(img, color, add_surf=None):
    img = img.copy()
    img.set_colorkey(color)
    mask = pygame.mask.from_surface(img)
    surf = mask.to_surface(setcolor=(0, 0, 0, 0), unsetcolor=color)
    if add_surf:
        base_surf = pygame.Surface(img.get_size())
        base_surf.fill(color)
        add_surf = (add_surf[0].convert(), add_surf[1])
        add_surf[0].set_colorkey(add_surf[1])
        base_surf.blit(add_surf[0], (0, 0))
        base_surf.blit(surf, (0, 0))
        base_surf.set_colorkey((0, 0, 0))
        return base_surf
    else:
        return surf

class AnimatedFoliage:
    def __init__(self, image, color_chain, motion_scale=1):
        self.motion_scale = motion_scale
        self.base_image = image.copy()
        self.color_chain = color_chain
        self.layers = []

        for i, color in enumerate(color_chain[::-1]):
            if i == 0:
                self.layers.append(extract_color(self.base_image, color))
            else:
                self.layers.append(extract_color(self.base_image, color, add_surf=(self.layers[-1], color_chain[::-1][i - 1])))

        self.layers = self.layers[::-1]

    def find_leaf_point(self):
        while True:
            point = (int(random.random() * self.layers[0].get_width()), int(random.random() * self.layers[0].get_height()))
            color = self.layers[0].get_at(point)
            if list(color)[:3] != [0, 0, 0]:
                return point

    def render(self, surf, pos, m_clock=0, seed=14):
        surf.blit(pygame.transform.rotate(self.layers[0], math.sin(m_clock * 0.8 + (2.7 * seed)) * 1.2), (pos[0] + math.sin(m_clock * 1.7 + (2.7 * seed)) * 3 * self.motion_scale, pos[1] + math.sin(m_clock + (2.2 * seed)) * 2 * self.motion_scale))
        surf.blit(self.base_image, pos)
        for i, layer in enumerate(self.layers):
            if i != 0:
                surf.blit(pygame.transform.rotate(layer, math.sin(m_clock * 1.1) * 1.5), (pos[0] + math.sin(m_clock * (1.25 * i) + (2.7 * seed)) * 3 * self.motion_scale, pos[1] + math.sin(m_clock * (1.25 * i) + (2.2 * seed)) * 2 * self.motion_scale))
            else:
                surf.blit(layer, pos)
