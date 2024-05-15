import os
import pygame
import json
import random
from Entitys.PlayerInfo import PlayerInfo, PlayerInfoSprite

HAUTEUR, LARGEUR = 1280 , 720
pygame.init()

class Entity(pygame.sprite.Sprite):
    def __init__(self, path):
        super().__init__()
        self.speed = 2.5
        self.is_dead = False
        self.strength_power = 1
        self.health = 100
        self.max_health = 100
        self.image = pygame.Surface((75, 75))
        self.image.fill((255, 0, 0))
        self.rect = self.image.get_rect()
        self.rect.center = (HAUTEUR // 2, LARGEUR // 2)
        self.name = "Entity"
        self.path = path
        self.show_player_information = False
        self.load_from_json(path)
        self.mouvements = random.choice(["up-down", "down-up", "left-right", "right-left", "carré", "losange", "diagonale"])


    def update(self):
        super().update()
        if self.rect.x < 50:
            self.rect.x = 50
        if self.rect.y < 0:
            self.rect.y = 0
        if self.rect.x > HAUTEUR - self.rect.width - 50:
            self.rect.x = HAUTEUR - self.rect.width -50
        if self.rect.y > LARGEUR - self.rect.height - 50:
            self.rect.y = LARGEUR - self.rect.height - 50




    def show_informations(self):
        self.show_player_information = not self.show_player_information

    def load_from_json(self, file_path):
        try:
            with open(file_path, 'r') as file:
                player_data_from_json = json.load(file)
                self.speed = player_data_from_json.get("speed", self.speed)
                self.strength_power = player_data_from_json.get("strength_power", self.strength_power)
                self.health = player_data_from_json.get("health", self.health)
                self.max_health = player_data_from_json.get("max_health", self.max_health)
                self.is_dead = player_data_from_json.get("True", self.is_dead)
                image_path = player_data_from_json.get("image_path")
                if image_path is not None or os.path.exists(image_path):
                    self.load_entity_image(image_path)
                if self.image:
                    self.rect = self.image.get_rect()
                    self.rect.center = (HAUTEUR // 2, LARGEUR // 2)
                self.name = player_data_from_json.get("name", "Entity")
        except FileNotFoundError:
            print(f"Erreur : fichier JSON introuvable - {file_path}")
        except json.JSONDecodeError:
            print(f"Erreur : fichier JSON malformé - {file_path}")
        except Exception as e:
            print(f"Erreur lors du chargement des données depuis le fichier JSON: {e}")

    def load_entity_image(self, image_path):
        try:
            self.image = pygame.image.load(image_path).convert_alpha()
            self.image = pygame.transform.scale(self.image, (75, 75))
        except pygame.error as e:
            print(f"Erreur lors du chargement de l'image : {image_path}: {e}")
            self.image = pygame.Surface((75, 75))
            self.image.fill((255, 0, 0))


