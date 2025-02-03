import time
from array import array

import moderngl
import pygame

from data.scripts.core_funcs import read_f

class MGL:
    def __init__(self):
        self.ctx = moderngl.create_context()
        self.textures = {}
        self.programs = {}
        self.quad_buffer = self.ctx.buffer(data=array('f', [
            # position (x, y) , texture coordinates (x, y)
            -1.0, 1.0, 0.0, 0.0,
            -1.0, -1.0, 0.0, 1.0,
            1.0, 1.0, 1.0, 0.0,
            1.0, -1.0, 1.0, 1.0,
        ]))
        self.vaos = {}

        self.initialize()

    def initialize(self):
        self.load_texture('misc/canvas')
        self.load_texture('misc/noise')
        self.load_texture('misc/end')
        self.compile_program('texture', 'texture', 'default_texture')
        self.compile_program('texture', 'main_display', 'game_display')

    def render(self, scroll, lights, ending):
        self.ctx.clear(0.09412, 0.64314, 0.90588)
        self.ctx.enable(moderngl.BLEND)
        if 'base_display' in self.textures:
            for tex in ['base_display', 'world_mask']:
                self.textures[tex].repeat_x = False
                self.textures[tex].repeat_y = False
            self.update_render('game_display', {
                'surface': self.textures['base_display'],
                'canvas': self.textures['misc/canvas'],
                'noise': self.textures['misc/noise'],
                'end_tex': self.textures['misc/end'],
                'world_mask': self.textures['world_mask'],
                'ui': self.textures['ui_surf'],
                'lights': lights,
                'time': time.time() % 10000,
                'scroll': scroll,
                'ending': ending,
                'pixel_dimensions': (320, 240),
                'window_dimensions': pygame.display.get_window_size(),
            })
        self.ctx.disable(moderngl.BLEND)

    def update_render(self, program_name, uniforms):
        self.update_shader(program_name, uniforms)
        self.vaos[program_name].render(mode=moderngl.TRIANGLE_STRIP)

    def update_shader(self, program_name, uniforms):
        tex_id = 0
        for uniform in uniforms:
            try:
                if type(uniforms[uniform]) == moderngl.texture.Texture:
                    uniforms[uniform].use(tex_id)
                    self.programs[program_name][uniform].value = tex_id
                    tex_id += 1
                else:
                    self.programs[program_name][uniform].value = uniforms[uniform]
            except:
                pass

    def compile_program(self, vert_src, frag_src, program_name):
        vert_raw = read_f('data/shaders/' + vert_src + '.vert')
        frag_raw = read_f('data/shaders/' + frag_src + '.frag')
        program = self.ctx.program(vertex_shader=vert_raw, fragment_shader=frag_raw)
        self.programs[program_name] = program
        self.vaos[program_name] = self.ctx.vertex_array(program, [(self.quad_buffer, '2f 2f', 'in_vert', 'in_texcoord')])

    def load_texture(self, name):
        surf = pygame.image.load('data/images/' + name + '.png').convert()
        self.pg2tx(surf, name)

    def pg2tx(self, surface, texture_name):
        channels = 4
        if texture_name not in self.textures:
            new_tex = self.ctx.texture(surface.get_size(), channels)
            new_tex.filter = (moderngl.NEAREST, moderngl.NEAREST)
            new_tex.swizzle = 'BGRA'
            self.textures[texture_name] = new_tex

        texture_data = surface.get_view('1')
        self.textures[texture_name].write(texture_data)
