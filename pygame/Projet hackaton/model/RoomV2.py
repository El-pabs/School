import os
import random
import pygame
import json

# Initialisation de pygame
pygame.init()

# Variables globales pour la taille de la fenêtre
Longueur = 1280
Hauteur = 720

class GenerateRoom(pygame.sprite.Sprite):
    """Classe de debug"""
    def __init__(self, map_image, doors):
        super().__init__()
        self.map_image = map_image
        self.doors = doors
        self.image = pygame.image.load(map_image)
        self.image = pygame.transform.scale(self.image, (Longueur, Hauteur))
        self.rect = self.image.get_rect()


    def draw(self, screen):
        screen.blit(self.image, self.rect)
        for door in self.doors:
            screen.blit(door.image, door.rect)


class Door(pygame.sprite.Sprite):
    """Classe de debug"""
    def __init__(self, door_direction):
        super().__init__()
        self.direction = door_direction
        self.image = pygame.Surface((75, 75))
        self.image.fill((255, 0, 0))
        self.rect = self.image.get_rect()
        self.set_position(self.direction)
    

    def set_position(self, door_direction):
        if door_direction == "nord":
            self.rect.center = (Longueur / 2, 0)
        elif door_direction == "sud":
            self.rect.center = (Longueur / 2, Hauteur)
        elif door_direction == "ouest":
            self.rect.center = (0, Hauteur / 2)
        elif door_direction == "est":
            self.rect.center = (Longueur, Hauteur / 2)


def select_map(__map_dir):
    files = []
    for file in os.listdir(__map_dir):
        potential_map = os.path.join(__map_dir, file)
        if os.path.isfile(potential_map):
            files.append(potential_map)

    if files:
        return random.choice(files)
    else:
        return None


def generate_doors(previous_door=None):
    directions = ["nord", "sud", "est", "ouest"]
    if previous_door:
        opposite_door = {
            "nord": "sud",
            "sud": "nord",
            "ouest": "est",
            "est": "ouest"
        }
        first_door = opposite_door[previous_door]
        directions.remove(first_door)
    else:
        first_door = random.choice(directions)
        directions.remove(first_door)
    second_door = random.choice(directions)
    return [Door(first_door), Door(second_door)]


class MapOfRoom(pygame.sprite.Sprite):
    """
    Réprensentation des infos à l'écran pour la minimap
    """
    def __init__(self, __map_dir, num_rooms):
        super().__init__()
        self.__map_dir = __map_dir
        self.__num_rooms = num_rooms
        self.__generate_path()
        self.rooms = []

    def generate_path(self):
        """_summary_

        Raises:
            FileNotFoundError: _description_
        """
        previous_door = None
        for _ in range(self.num_rooms):
            selected_map = select_map(self.__map_dir)
            if not selected_map:
                raise FileNotFoundError(
                    "Aucune carte trouvée dans le répertoire spécifié.")
            doors = generate_doors(previous_door)
            # Utiliser la direction de la deuxième porte
            previous_door = doors[1].direction
            self.rooms.append(GenerateRoom(selected_map, doors))

    def draw(self, screen):
        for room in self.rooms:
            room.draw(screen)

    @property
    def num_rooms(self):
        return self.__num_rooms


#Debug direct sur la classe
with open('data.json', 'r') as f:
    data = json.load(f)

map_of_room = MapOfRoom(data["__map_dir"], num_rooms=4)

screen = pygame.display.set_mode((Longueur, Hauteur))
pygame.display.set_caption("Example")

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    screen.fill((0, 0, 0))
    map_of_room.draw(screen)
    pygame.display.flip()

pygame.quit()
