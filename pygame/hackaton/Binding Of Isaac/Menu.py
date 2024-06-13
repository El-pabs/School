"""
Ce module contient le menu principal du jeu "Binding of Isaac".
"""

import pygame, sys
from Menu_button import Button
import random
from Hero import *


pygame.init()

width, height = 1280, 720

SCREEN = pygame.display.set_mode((width, height), pygame.NOFRAME)
pygame.display.set_caption("Menu")
surface = pygame.Surface((width, height), pygame.SRCALPHA)

BG = pygame.image.load("assets/Graphics/image_jeu.png")
BG = pygame.transform.scale(BG, (width, height))

music_files = ["assets/sound/Menu song.mp3","assets/sound/Menu song.mp3","assets/sound/Menu song.mp3", "assets/sound/Menu song 2.mp3"]
music = random.choice(music_files)
pygame.mixer.music.load(music)
pygame.mixer.music.set_volume(0.4)
pygame.mixer.music.play(-1)


difficulty = 'NORMAL'

def get_font(size):
    """
    Cette fonction retourne la police souhaitée.
    """
    return pygame.font.Font("assets/font/Hammer God Font DEMO.ttf", size)

def play():
    """
    Cette fonction gère l'écran de jeu.
    """
    while True:
        from main import game
        game(SCREEN, get_font(36))


def options():
    """
    Cette fonction gère l'écran des options.
    """
    global difficulty
    while True:
        '''
        Cette boucle permet de gérer l'écran des options.
        les options sont les suivantes: EASY, NORMAL, HARD
        '''
        OPTIONS_MOUSE_POS = pygame.mouse.get_pos()

        SCREEN.fill("white")

        OPTIONS_TEXT = get_font(45).render("Chose your game difficulty", True, "Black")
        OPTIONS_RECT = OPTIONS_TEXT.get_rect(center=(640, 100))
        SCREEN.blit(OPTIONS_TEXT, OPTIONS_RECT)

        OPTIONS_EASY = Button(image=None, pos=(200, 360),
                             text_input="EASY", font=get_font(75), base_color="Black",hovering_color='Grey', selected=difficulty=='EASY')
        OPTIONS_NORMAL = Button(image=None, pos=(640, 360),
                               text_input="NORMAL", font=get_font(75), base_color="Black",hovering_color='Grey', selected=difficulty=='NORMAL')
        OPTIONS_HARD = Button(image=None, pos=(1080, 360),
                             text_input="HARD", font=get_font(75), base_color="Black",hovering_color="Grey", selected=difficulty=='HARD')
        OPTIONS_BACK = Button(image=None, pos=(640, 650),
                              text_input="GO BACK", font=get_font(75), base_color="Black", hovering_color="Grey")

        OPTIONS_EASY.base_color = "Grey" if OPTIONS_EASY.selected else "Black"
        OPTIONS_NORMAL.base_color = "Grey" if OPTIONS_NORMAL.selected else "Black"
        OPTIONS_HARD.base_color = "Grey" if OPTIONS_HARD.selected else "Black"

        mouse_pos = pygame.mouse.get_pos()
        for button in [OPTIONS_BACK, OPTIONS_EASY, OPTIONS_NORMAL, OPTIONS_HARD]:
            button.changeColor(mouse_pos)
            button.update(SCREEN)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if OPTIONS_BACK.checkForInput(OPTIONS_MOUSE_POS):
                    return difficulty
                if OPTIONS_EASY.checkForInput(OPTIONS_MOUSE_POS):
                    difficulty = EASY
                    OPTIONS_EASY.selected = True
                    OPTIONS_NORMAL.selected = False
                    OPTIONS_HARD.selected = False
                if OPTIONS_NORMAL.checkForInput(OPTIONS_MOUSE_POS):
                    difficulty = NORMAL
                    OPTIONS_EASY.selected = False
                    OPTIONS_NORMAL.selected = True
                    OPTIONS_HARD.selected = False
                if OPTIONS_HARD.checkForInput(OPTIONS_MOUSE_POS):
                    difficulty = HARD
                    OPTIONS_EASY.selected = False
                    OPTIONS_NORMAL.selected = False
                    OPTIONS_HARD.selected = True

        pygame.display.update()

def main_menu():
    """
    Cette fonction gère le menu principal.
    """
    while True:
        SCREEN.blit(BG, (0, 0))

        MENU_MOUSE_POS = pygame.mouse.get_pos()

        MENU_TEXT = pygame.image.load("assets/Graphics/Menu.png")
        MENU_RECT = MENU_TEXT.get_rect(center=(640, 100))

        PLAY_BUTTON = Button(image=None, pos=(640, 250),
                             text_input="PLAY", font=get_font(75), base_color="#d7fcd4", hovering_color="White")
        OPTIONS_BUTTON = Button(image=None, pos=(640, 400),
                                text_input="DIFFICULTY", font=get_font(75), base_color="#d7fcd4", hovering_color="White")
        QUIT_BUTTON = Button(image=None, pos=(640, 550),
                             text_input="QUIT", font=get_font(75), base_color="#d7fcd4", hovering_color="White")

        SCREEN.blit(MENU_TEXT, MENU_RECT)

        for button in [PLAY_BUTTON, OPTIONS_BUTTON, QUIT_BUTTON]:
            button.changeColor(MENU_MOUSE_POS)
            button.update(SCREEN)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if PLAY_BUTTON.checkForInput(MENU_MOUSE_POS):
                    pygame.mixer.music.stop()
                    play()
                if OPTIONS_BUTTON.checkForInput(MENU_MOUSE_POS):
                    options()
                if QUIT_BUTTON.checkForInput(MENU_MOUSE_POS):
                    pygame.quit()
                    sys.exit()

        pygame.display.update()

main_menu()

