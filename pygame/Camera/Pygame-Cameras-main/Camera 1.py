import pygame
from random import randint

# Définition de la classe Tree, qui est un type de sprite dans le jeu
class Tree(pygame.sprite.Sprite):
    def __init__(self,pos,group):
        # Appel du constructeur de la classe parente (Sprite)
        super().__init__(group)
        # Chargement de l'image pour le sprite
        self.image = pygame.image.load('graphics/tree.png').convert_alpha()
        # Définition du rectangle pour le sprite
        self.rect = self.image.get_rect(topleft = pos)

# Définition de la classe Player, qui représente le personnage du joueur dans le jeu
class Player(pygame.sprite.Sprite):
    def __init__(self,pos,group):
        # Appel du constructeur de la classe parente (Sprite)
        super().__init__(group)
        # Chargement de l'image pour le sprite
        self.image = pygame.image.load('graphics/player.png').convert_alpha()
        # Définition du rectangle pour le sprite
        self.rect = self.image.get_rect(center = pos)
        # Initialisation des variables de mouvement
        self.direction = pygame.math.Vector2()
        self.speed = 5

    # Gestion des entrées du joueur
    def input(self):
        keys = pygame.key.get_pressed()

        if keys[pygame.K_UP]:
            self.direction.y = -1
        elif keys[pygame.K_DOWN]:
            self.direction.y = 1
        else:
            self.direction.y = 0

        if keys[pygame.K_RIGHT]:
            self.direction.x = 1
        elif keys[pygame.K_LEFT]:
            self.direction.x = -1
        else:
            self.direction.x = 0

    # Mise à jour du joueur
    def update(self):
        self.input()
        self.rect.center += self.direction * self.speed

class CameraGroup(pygame.sprite.Group):
    def __init__(self):
        super().__init__()
        self.display_surface = pygame.display.get_surface()

        # Définition du décalage de la caméra
        self.offset = pygame.math.Vector2()
        self.half_w = self.display_surface.get_size()[0] // 2 # moitié de la largeur de l'écran
        self.half_h = self.display_surface.get_size()[1] // 2 # moitié de la hauteur de l'écran

        # sol
        self.ground_surface = pygame.image.load('graphics/ground.png').convert_alpha()
        self.ground_rect = self.ground_surface.get_rect(topleft = (0,0))

    def center_target_camera(self, target):
        self.offset.x = target.rect.centerx - self.half_w
        self.offset.y = target.rect.centery - self.half_h

    def custom_draw(self, player):

        self.center_target_camera(player)

        # Dessin du sol
        ground_offset = self.ground_rect.topleft - self.offset # décalage du sol par rapport à la caméra
        self.display_surface.blit(self.ground_surface, ground_offset) # dessin du sol

        # elements actif
        for sprite in sorted(self.sprites(), key = lambda sprite: sprite.rect.centery): # tri des sprites par ordre de position y
            offset_pos = sprite.rect.topleft - self.offset # position du sprite avec décalage de la caméra
            self.display_surface.blit(sprite.image, offset_pos) # dessin du sprite

# Initialisation de Pygame
pygame.init()
# Définition de la fenêtre d'affichage
screen = pygame.display.set_mode((1280,720))
# Initialisation de l'horloge
clock = pygame.time.Clock()

# Configuration
camera_group = CameraGroup()
player = Player((640,360),camera_group)

# Création des arbres
for i in range(20):
    random_x = randint(0,1000)
    random_y = randint(0,1000)
    Tree((random_x,random_y),camera_group)

# Boucle de jeu
while True:
    # Boucle d'événements
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            exit()

    # Remplissage de l'écran avec une couleur
    screen.fill('#71ddee')
    # Mise à jour des sprites dans le groupe
    camera_group.update()

    # Dessin des sprites sur l'écran
    camera_group.custom_draw(player)

    # Mise à jour de l'affichage
    pygame.display.update()
    # Limitation du taux de rafraîchissement
    clock.tick(60)