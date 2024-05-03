import pygame, os, json
try:
	from .core_funcs import *
except:
	from core_funcs import *

COLORKEY = (0, 0, 0)

def load_spritesheet(spritesheet):
    rows = []
    spritesheet_dat = []
    for y in range(spritesheet.get_height()):
        c = spritesheet.get_at((0, y))
        c = (c[0], c[1], c[2])
        if c == (255, 255, 0):
            rows.append(y)
    for row in rows:
        row_content = []
        for x in range(spritesheet.get_width()):
            c = spritesheet.get_at((x, row))
            c = (c[0], c[1], c[2])
            if c == (255, 0, 255): # found tile
                x2 = 0
                while True:
                    x2 += 1
                    c = spritesheet.get_at((x + x2, row))
                    c = (c[0], c[1], c[2])
                    if c == (0, 255, 255):
                        width = x2
                        break
                y2 = 0
                while True:
                    y2 += 1
                    c = spritesheet.get_at((x, row + y2))
                    c = (c[0], c[1], c[2])
                    if c == (0, 255, 255):
                        height = y2
                        break
                img = clip(spritesheet, x + 1, row + 1, x2 - 1, y2 - 1)
                img.set_colorkey(COLORKEY)
                row_content.append(img)
        spritesheet_dat.append(row_content)
    return spritesheet_dat

def load_spritesheets(path):
    spritesheet_list = os.listdir(path)
    spritesheets = {}
    spritesheets_data = {}
    for img_file in spritesheet_list:
        if img_file.split('.')[-1] == 'png':
            spritesheet_dat = load_spritesheet(pygame.image.load(path + '/' + img_file).convert())
            spritesheets[img_file.split('.')[0]] = spritesheet_dat
            try:
                dat = read_f(path + '/' + img_file.split('.')[0] + '.json')
                spritesheets_data[img_file.split('.')[0]] = json.loads(dat)
            except FileNotFoundError:
                pass

    return spritesheets, spritesheets_data

def get_img(spritesheets, img_loc):
    return spritesheets[img_loc[0]][img_loc[1]][img_loc[2]]
