from player import *
from ennemy import *
from movingFloor import *
import pygame
from sys import exit
import time

pygame.init()
clock = pygame.time.Clock()

# Mes fonction #
#################################################################
def exitgame():
    global running
    running = False

# Programme principale #
#################################################################

HEIGHTT = 500
WIDTHH = 1500

surface = pygame.display.set_mode((WIDTHH, HEIGHTT))
# surface.fill(0,250,0) ancienne méthode avant le BG
surface.blit(pygame.image.load("img/mountain.png"), (0, 0))

# Evenement utilisateur
ADD_ENEMY = pygame.USEREVENT + 1
MOVING_BIRD = pygame.USEREVENT + 2
# genere au top de 2s
pygame.time.set_timer(ADD_ENEMY, 2000)
#genere au top de 150ms
pygame.time.set_timer(MOVING_BIRD, 150)
# nom fenetre
pygame.display.set_caption("flying bird")

# Score du jeu
maPolice = pygame.font.SysFont("arial", 30)
monTxt = maPolice.render("score = " + str(Ennemy.score), True, (225, 0, 0))

# Son de tir
monSon = pygame.mixer.Sound("Sound/23423.mp3")
monSon1 = pygame.mixer.Sound("Sound/cquirobin.mp3")

# collection joueur et ennemi SPRITE (objet 2d)
p1 = Player()

allPlayerAndEnnemies = pygame.sprite.Group()
allPlayerAndEnnemies.add(p1)

# collection ennemi SPRITE
allEnnemies = pygame.sprite.Group()

# image dans le coin superieur gauche
f1 = Movingfloor(0, 0)
# image dans un coin superieur droit
f2 = Movingfloor(WIDTHH, 0)

# collection cailloux >>> écran en mouvement SPRITE
allFloor = pygame.sprite.Group()
allFloor.add(f1)
allFloor.add(f2)

vandepute = pygame.image.load("img/vandepute.png")

def reset_phoenix_game():
    global p1, allEnnemies, allPlayerAndEnnemies, Ennemy

    # Reset the player's position
    p1.rect.midbottom = (WIDTHH/2, HEIGHTT/2)

    # Clear all the enemies
    allEnnemies.empty()
    allPlayerAndEnnemies.empty()

    # Reset the player and add it back to the groups
    p1 = Player()
    allPlayerAndEnnemies.add(p1)

    # Reset the score
    Ennemy.score = 0

# =============
# GAME LOOP #
# =============
running =True
def phoenix_play():
    while running:
        for eventi in pygame.event.get():
            if eventi.type == pygame.QUIT:
                pygame.quit()
                exit()
            if eventi.type == pygame.KEYDOWN:
                if eventi.key == pygame.K_ESCAPE:
                    exitgame()
            # tick a 2000ms
            # ajoute un ennemi aléatoirement
            if eventi.type == ADD_ENEMY:
                e = Ennemy(WIDTHH, HEIGHTT)
                allEnnemies.add(e)
                allPlayerAndEnnemies.add(e)
                son = random.choice([monSon, monSon1])
                son.play()
            # tick a 150 ms
            # permet à l'oiseau de voler
            if eventi.type == MOVING_BIRD:
                p1.playerAnimation()
            # on dessine le background
            surface.blit(pygame.image.load("img/mountain.png"), (0, 0))

            monTxt = maPolice.render("score = " + str(Ennemy.score), True, (225, 0, 0))
            surface.blit(monTxt, (WIDTHH - 150,0))
            # On récupère les touches appuyées en début de frame
            pressed_keys = pygame.key.get_pressed()
            # On update le Sprite du joueur en fonction des touches
            p1.update(pressed_keys, WIDTHH, HEIGHTT)

            allEnnemies.update()

            allFloor.update(WIDTHH)

            # Dessine tous les sprites cailloux
            for thisFloor in allFloor:
                surface.blit(thisFloor.surf, thisFloor.rect)
            for thisSprite in allPlayerAndEnnemies:
                surface.blit(thisSprite.surf, thisSprite.rect)
            surface.blit(vandepute, (WIDTHH - 200, 20))
            if pygame.sprite.spritecollideany(p1, allEnnemies):
                pygame.mixer.music.stop()
                pygame.mixer.music.load("Sound/Allahu Akbar Sound Effect - Free Download HD.mp3")
                pygame.mixer.music.set_volume(0.1)
                pygame.mixer.music.play()
                p1.kill()
                time.sleep(1)
                return f"Score réalisé : {Ennemy.score}"

            # On rafraîchit la surface
            pygame.display.flip()

            clock.tick(30)

