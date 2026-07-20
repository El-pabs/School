import pygame, sys
import random
from button import Button
from platformer import *
from Pong import *
from runner import *
from phoenix import *
pygame.init()
width = 1280
height = 720

# Initialiser l'écran de jeu
SCREEN = pygame.display.set_mode((width, height))
pygame.display.set_caption("Menu")

# Charger l'image de fond
BG = pygame.image.load("assets/Background.png")

# Variable pour contrôler la musique
Play_music = True
click = pygame.mixer.Sound("Sound/clicking.mp3")
# Fonction pour afficher le score et les options de fin de partie
def tempo(game, result):
    pygame.mixer.music.stop()
    SCREEN = pygame.display.set_mode((width, height))
    # créer des boutons pour que le joueur puisse choisir de rejouer ou de retourner au menu principal
    play_again_button = Button(image=None, pos=(width / 2, height / 2),
                               text_input="Play Again", font=get_font(75), base_color="Green",
                               hovering_color=(144, 238, 144))  # Vert clair
    main_menu_button = Button(image=None, pos=(width / 2, height / 2 + 100),
                              text_input="Main Menu", font=get_font(75), base_color="Red",
                              hovering_color=(240, 128, 128))  # Rouge clair

    # créer un objet texte pour afficher le résultat
    result_text = get_font(35).render(result, True, "cyan")
    result_pos = (width / 2 - result_text.get_width() / 2, 50)

    while True:
        mouse_pos = pygame.mouse.get_pos()
        for button in [play_again_button, main_menu_button]:
            button.changeColor(mouse_pos)
            button.update(SCREEN)

        # dessiner le texte du résultat
        SCREEN.blit(result_text, result_pos)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if play_again_button.checkForInput(mouse_pos):
                    reset_game_platformer()  # réinitialiser l'état du jeu
                    reset_game_pong()
                    reset_game_runner()
                    reset_phoenix_game()
                    play()
                if main_menu_button.checkForInput(mouse_pos):
                    reset_game_platformer()  # réinitialiser l'état du jeu
                    reset_game_pong()
                    reset_game_runner()
                    reset_phoenix_game()
                    main_menu()  # retourner au menu principal

        pygame.display.update()

# Fonction pour obtenir la police de caractères
def get_font(size):
    return pygame.font.Font("assets/font.ttf", size)

# Fonction pour jouer de la musique
def play_music():
    if Play_music:
        music_files = ["Sound/Music/music (1).mp3", "Sound/Music/music (2).mp3", "Sound/Music/music (3).mp3",
                       "Sound/Music/music (4).mp3"]
        music_file = random.choice(music_files)  # Sélectionner un fichier de musique aléatoire
        pygame.mixer.music.load(music_file)
        pygame.mixer.music.play(-1) # Jouer la musique en boucle

# Fonction pour jouer au jeu
def play():
    SCREEN = pygame.display.set_mode((width, height))
    while True:
        # Créer des boutons pour chaque jeu
        PONG_BUTTON = Button(image=None, pos=(width / 2, height / 2 + 100),
                             text_input="PONG", font=get_font(75), base_color="Green",
                             hovering_color=(144, 238, 144))  # Vert clair
        PLATFORMER_BUTTON = Button(image=None, pos=(width/ 2, height / 2- 200),
                                   text_input="PLATFORMER", font=get_font(75), base_color="Purple",
                                   hovering_color=(147, 112, 219))  # Violet moyen
        RUNNER_BUTTON = Button(image=None, pos=(width / 2, height / 2 + -50),
                              text_input="RUNNER", font=get_font(75), base_color="Blue",
                              hovering_color=(135, 206, 250))  # Bleu clair
        PHOENIX_BUTTON = Button(image=None, pos=(width / 2, height / 2 + 250),
                                text_input="VANDEVILLE DESTROYER", font=get_font(60), base_color="Red",
                                hovering_color=(255, 99, 71))  # Rouge clair

        while True:
            mouse_pos = pygame.mouse.get_pos()
            for button in [PONG_BUTTON, PLATFORMER_BUTTON, RUNNER_BUTTON, PHOENIX_BUTTON]:
                button.changeColor(mouse_pos) # Changer la couleur du bouton si la souris est dessus
                button.update(SCREEN)

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    sys.exit()
                if event.type == pygame.MOUSEBUTTONDOWN:
                    if PONG_BUTTON.checkForInput(mouse_pos): # Si le bouton PONG est cliqué
                        SCREEN = pygame.display.set_mode((width_pong, height_pong))
                        play_music()
                        result = pong_play()  # Appeler la fonction principale du jeu Pong et obtenir le résultat
                        SCREEN = pygame.display.set_mode((width, height))
                        tempo("pong", result)

                    if PLATFORMER_BUTTON.checkForInput(mouse_pos): # Si le bouton PLATFORMER est cliqué
                        SCREEN = pygame.display.set_mode((WIDTH, HEIGHT))
                        play_music()
                        result = Platform_play()  # Appeler la fonction principale du jeu Platformer et obtenir le résultat
                        SCREEN = pygame.display.set_mode((width, height))
                        tempo('platformer', str(result))  # Convertir le score en une chaîne de caractères

                    if RUNNER_BUTTON.checkForInput(mouse_pos): # Si le bouton RUNNER est cliqué
                        if Play_music: # Si la musique est activée
                            bg_music = pygame.mixer.Sound('Sound/music_ninja.wav') # Charger la musique de fond
                            bg_music.set_volume(0.1)  # Définir le volume de la musique
                            bg_music.play(loops=-1) # Jouer la musique en boucle
                        SCREEN = pygame.display.set_mode((800, 400))
                        print('Game made by : El_Pablo')
                        result = runner_play()
                        if Play_music: # Si la musique est activée
                            bg_music.stop() # Arrêter la musique
                        SCREEN = pygame.display.set_mode((width, height))
                        tempo('runner', str(result))

                    if PHOENIX_BUTTON.checkForInput(mouse_pos): # Si le bouton PHOENIX est cliqué
                        SCREEN = pygame.display.set_mode((1500,500))
                        if Play_music:  # Si la musique est activée
                            bg_music = pygame.mixer.Sound('Sound/haava.mp3')  # Charger la musique de fond
                            bg_music.set_volume(0.1)  # Définir le volume de la musique
                            bg_music.play(loops=-1)  # Jouer la musique en boucle
                        result = phoenix_play()
                        if Play_music:  # Si la musique est activée
                            bg_music.stop()  # Arrêter la musique
                        SCREEN = pygame.display.set_mode((width, height))
                        tempo('phoenix', str(result))

            pygame.display.update()

# Fonction pour les options
def options():
    global Play_music
    while True:
        OPTIONS_MOUSE_POS = pygame.mouse.get_pos()

        SCREEN.fill("white")

        OPTIONS_TEXT = get_font(45).render("Play Music?", True, "Black")
        OPTIONS_RECT = OPTIONS_TEXT.get_rect(center=(640, 260))
        SCREEN.blit(OPTIONS_TEXT, OPTIONS_RECT)

        YES_BUTTON = Button(image=None, pos=(540, 360),
                            text_input="YES", font=get_font(75), base_color="Green" if Play_music else "Black", hovering_color="Green")
        NO_BUTTON = Button(image=None, pos=(740, 360),
                           text_input="NO", font=get_font(75), base_color="Red" if not Play_music else "Black", hovering_color="Red")

        OPTIONS_BACK = Button(image=None, pos=(640, 460),
                            text_input="BACK", font=get_font(75), base_color="Black", hovering_color="Green")

        for button in [YES_BUTTON, NO_BUTTON, OPTIONS_BACK]:
            button.changeColor(OPTIONS_MOUSE_POS)
            button.update(SCREEN)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if YES_BUTTON.checkForInput(OPTIONS_MOUSE_POS):
                    click.play()
                    Play_music = True
                if NO_BUTTON.checkForInput(OPTIONS_MOUSE_POS):
                    click.play()
                    Play_music = False
                if OPTIONS_BACK.checkForInput(OPTIONS_MOUSE_POS):
                    click.play()
                    main_menu()

        pygame.display.update()

# Fonction pour le menu principal
def main_menu():
    while True:
        SCREEN.blit(BG, (0, 0))

        MENU_MOUSE_POS = pygame.mouse.get_pos()

        MENU_TEXT = get_font(100).render("MAIN MENU", True, "#b68f40")
        MENU_RECT = MENU_TEXT.get_rect(center=(640, 100))

        PLAY_BUTTON = Button(image=pygame.image.load("assets/Play Rect.png"), pos=(640, 250),
                             text_input="PLAY", font=get_font(75), base_color="#d7fcd4", hovering_color="White")
        OPTIONS_BUTTON = Button(image=pygame.image.load("assets/Options Rect.png"), pos=(640, 400),
                                text_input="OPTIONS", font=get_font(75), base_color="#d7fcd4", hovering_color="White")
        QUIT_BUTTON = Button(image=pygame.image.load("assets/Quit Rect.png"), pos=(640, 550),
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
                    click.play()
                    play()
                if OPTIONS_BUTTON.checkForInput(MENU_MOUSE_POS):
                    click.play()
                    options()
                if QUIT_BUTTON.checkForInput(MENU_MOUSE_POS):
                    pygame.quit()
                    sys.exit()

        pygame.display.update()

# Appeler la fonction du menu principal
main_menu()