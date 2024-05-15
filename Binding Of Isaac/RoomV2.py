import os
import random
import pygame
import json

# Initialisation de pygame
pygame.init()

# Variables globales pour la taille de la fenêtre
Longueur = 1280
Hauteur = 720

doors_group = pygame.sprite.Group()


class GenerateRoom(pygame.sprite.Sprite):
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
    def __init__(self, door_direction):
        super().__init__()
        self.direction = door_direction
        self.image = pygame.Surface((200, 200))
        self.image.fill((255, 0, 0))
        self.rect = self.image.get_rect()
        self.set_position(self.direction)
        doors_group.add(self)  # Add the door to the doors_group

    def set_position(self, door_direction):
        if door_direction == "nord":
            self.rect.center = (Longueur / 2, 0)
        elif door_direction == "sud":
            self.rect.center = (Longueur / 2, Hauteur)
        elif door_direction == "ouest":
            self.rect.center = (0, Hauteur / 2)
        elif door_direction == "est":
            self.rect.center = (Longueur, Hauteur / 2)


def select_map(map_dir):
    files = []
    for file in os.listdir(map_dir):
        potential_map = os.path.join(map_dir, file)
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
    def __init__(self, map_dir, num_rooms):
        super().__init__()
        self.map_dir = map_dir
        self.num_rooms = num_rooms
        self.rooms = []
        self.generate_path()

    def generate_path(self):
        previous_door = None
        for _ in range(self.num_rooms):
            selected_map = select_map(self.map_dir)
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


# Lire les données JSON
with open('data.json', 'r') as f:
    data = json.load(f)

# Créer l'objet MapOfRoom avec le nombre de pièces souhaité
map_of_room = MapOfRoom(data["map_dir"], num_rooms=4)

# Initialiser l'écran de pygame
