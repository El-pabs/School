import pygame
from sys import exit
from random import randint

pygame.init()

game_running = True

# dimensions de la fenêtre
width_pong = 800
height_pong = int(400)

# créer la fenêtre
screen = pygame.display.set_mode((width_pong,height_pong))
pygame.display.set_caption("My pong")
FPS = 60

# boule
DIM_BOULE = 10
boule = pygame.Rect(width_pong/2, height_pong/2, DIM_BOULE, DIM_BOULE)
vitesse_boule = 5
vitesse_boule_initiale = 2
boule_dir = boule.copy()

# texte
font = pygame.font.Font(None, 50)

# ligne pointilée variable
separateur = []
N = 10 # nombre de pointillés
largeur_separateur = 2
hauteur_separateur = height_pong/N
offset = 20

# créer les pointillés
for i in range(N):
    x = width_pong/2 - largeur_separateur/2
    y = (i * hauteur_separateur) + offset/2
    separateur.append(pygame.Rect(x, y, largeur_separateur, hauteur_separateur- offset))

# classe joueur
class Joueur:
    LARGEUR = 15
    HAUTEUR = 50
    VITESSE = 5

    def __init__(self, pos=(0,0)):
        self.rect = pygame.Rect(pos[0], pos[1], self.LARGEUR, self.HAUTEUR)
        self.score = 0

    def deplacer_haut(self):
        self.rect.y -= self.VITESSE

    def deplacer_bas(self):
        self.rect.y += self.VITESSE

    def afficher_score(self):
        return font.render(str(self.score), True, "white")


def changer_vitesse_boule(boule_dir, vitesse):
    boule_dir.x = vitesse if boule_dir.x > 0 else -vitesse # si la boule va vers la droite, on lui donne une vitesse positive, sinon négative
    boule_dir.y = vitesse if boule_dir.y > 0 else -vitesse # si la boule va vers le bas, on lui donne une vitesse positive, sinon négative


def direction_y_boule(x):
    return x*0.3


def deplacer_boule(boule, boule_dir):
    global game_running
    global vitesse_boule
#   rebondir sur les top et bottom
    if boule.top <= 0 or boule.bottom >= height_pong:
        boule_dir.y = -boule_dir.y

#   marquer un point et réinitialiser la boule
    if boule.left <=0 :
        joueur_droite.score += 1
        initalisation_boule(boule, boule_dir)
        vitesse_boule = 5
    if boule.right >= width_pong:
        joueur_gauche.score += 1
        initalisation_boule(boule, boule_dir)
        vitesse_boule = 5
    boule.x += boule_dir.x
    boule.y += boule_dir.y


def initalisation_boule(boule, boule_dir):
    boule.x = width_pong/2
    boule.y = randint(int(height_pong / 4), int(height_pong - height_pong / 4))
    changer_vitesse_boule(boule_dir, -vitesse_boule_initiale)


def check_collision(boule, joueur_droite, joueur_gauche):
    global vitesse_boule
    if boule.colliderect(joueur_droite):
        changer_vitesse_boule(boule_dir, vitesse_boule)
        boule_dir.x = - boule_dir.x
        # boule.center retourne un tuple (x,y) du centre de la boule
        boule_dir.y = direction_y_boule(boule.center[1] - joueur_droite.rect.center[1])
        vitesse_boule += 0.1

    if boule.colliderect(joueur_gauche):
        changer_vitesse_boule(boule_dir, vitesse_boule)
        boule_dir.x = - boule_dir.x
        # boule.center retourne un tuple (x,y) du centre de la boule
        boule_dir.y = direction_y_boule(boule.center[1] - joueur_gauche.rect.center[1])
        vitesse_boule += 0.1


def dessin(joueur_droite, joueur_gauche, boule):
    screen.fill("black")

#   dessiner le séparateur
    for s in separateur:
        pygame.draw.rect(screen, "white", s)

#   dessiner les joueurs
    pygame.draw.rect(screen, "white", joueur_gauche.rect)
    pygame.draw.rect(screen, "white", joueur_droite.rect)

#   dessiner la boule
    pygame.draw.ellipse(screen, "white", boule)

#   dessiner les scores
    screen.blit(joueur_droite.afficher_score(), (width_pong/2 + 20, 10))
    screen.blit(joueur_gauche.afficher_score(), (width_pong/2 - 40, 10))

#   dessiner la vitesse de la boule
    vitesse_text = font.render("Speed: " + str(round(vitesse_boule,1)), True, "white") # arrondir la vitesse à 1 chiffre après la virgule
    screen.blit(vitesse_text, (10, 10)) # afficher la vitesse en haut à gauche

    pygame.display.flip()

# créer instances des joueurs
joueur_gauche = Joueur((5, height_pong/2 - Joueur.HAUTEUR/2))
joueur_droite = Joueur((width_pong - Joueur.LARGEUR - 5, (height_pong/2 - Joueur.HAUTEUR/2)))

def reset_game_pong():
    global joueur_gauche, joueur_droite
    # Reset the scores
    joueur_gauche.score = 0
    joueur_droite.score = 0




def pong_play():
    clock = pygame.time.Clock()
    initalisation_boule(boule, boule_dir)
    game_running = False
    colors = [
        (255, 0, 0),  # Red
        (0, 0, 255),  # Blue
        (255, 255, 0),  # Yellow
        (255, 0, 255),  # Magenta
        (255, 255, 255),  # White
        (0, 0, 0),  # Black
        (128, 0, 0),  # Maroon
        (128, 128, 0),  # Olive
        (0, 128, 0),  # Dark Green
        (128, 0, 128),  # Purple
        (0, 128, 128),  # Teal
        (0, 0, 128),  # Navy
        (128, 128, 128)  # Gray
    ]
    start_time = None  # Initialiser le temps de début

    while True:
        if start_time is None:  # enregistrer le temps de début si non défini
            start_time = pygame.time.get_ticks()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()

            # obtenir le temps actuel en secondes
        current_time = pygame.time.get_ticks() // 1000

        # changer la couleur toutes les secondes
        color = colors[current_time % len(colors)]


        keys = pygame.key.get_pressed()
        if keys[pygame.K_z] and joueur_gauche.rect.y > 0:
            joueur_gauche.deplacer_haut()
        if keys[pygame.K_s] and joueur_gauche.rect.y < height_pong - Joueur.HAUTEUR:
            joueur_gauche.deplacer_bas()
        if keys[pygame.K_UP] and joueur_droite.rect.y > 0:
            joueur_droite.deplacer_haut()
        if keys[pygame.K_DOWN] and joueur_droite.rect.y < height_pong - Joueur.HAUTEUR:
            joueur_droite.deplacer_bas()

        # déplacer la boule
        deplacer_boule(boule, boule_dir)

        # vérifier les collisions
        check_collision(boule, joueur_droite, joueur_gauche)

        # dessiner les éléments
        dessin(joueur_droite, joueur_gauche, boule)


        if joueur_gauche.score >= 10 or joueur_droite.score >= 10:
            player_win = "Le joueur de gauche" if joueur_gauche.score >= 10 else "Le joueur de droite"

            end_time = pygame.time.get_ticks()  # enregistrer le temps de fin
            total_seconds = (end_time - start_time) // 1000  # calculer le temps total en secondes
            minutes = total_seconds // 60  # Calculer les minutes
            seconds = total_seconds % 60  # Calculer les secondesr
            return f"{player_win} a gagné"
            start_time = None  # Réinitialiser le temps de début

        clock.tick(FPS)


            # # afficher le menu
            #  # créer les textes
            # pong_text = font.render("Pong the Game", True, color)
            # player_win_text = font.render(f"{player_win} a gagné", True, color) if "player_win" in locals() else None # Afficher le joueur gagnant si défini
            # play_message_text = font.render("Appuyer sur espace pour jouer", True, color) # Message de jeu
            # time_played_text = font.render("Time played: {:02d}:{:02d}".format(minutes, seconds), True, color) if "minutes" in locals() and "seconds" in locals() else None
            # # Afficher le temps joué si défini
            #
            # # calculer les positions des textes
            # pong_pos = ((width_pong - pong_text.get_width()) // 2, (height_pong - pong_text.get_height()) // 2 - 125)
            # player_win_pos = ((width_pong - player_win_text.get_width()) // 2, (height_pong - player_win_text.get_height()) // 2 - 75) if player_win_text else None
            # play_message_pos = ((width_pong - play_message_text.get_width()) // 2, (height_pong - play_message_text.get_height()) // 2 + 25)
            # time_played_pos = ((width_pong - time_played_text.get_width()) // 2, play_message_pos[1] - 50) if time_played_text else None
            #
            #
            # # remplir l'écran
            # screen.fill("cyan")
            #
            # # dessiner les textes
            # screen.blit(pong_text, pong_pos)
            # if player_win_text:
            #     screen.blit(player_win_text, player_win_pos)
            # screen.blit(play_message_text, play_message_pos)
            # if time_played_text:
            #     screen.blit(time_played_text, time_played_pos)
            #
            # keys = pygame.key.get_pressed()
            # if keys[pygame.K_SPACE]:
            #     game_running = True
            #     joueur_gauche.score = 0
            #     joueur_droite.score = 0
            #      vitesse_boule = 5

            
        pygame.display.flip()

