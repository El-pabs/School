import pygame
import random


class Ennemy(pygame.sprite.Sprite):
	score = 0

	def __init__(self, WIDTH, HEIGHT):
		super(Ennemy, self).__init__()
		image = random.choice(["img/2024-04-27_01h12_44.png", "img/2024-04-27_01h13_01.png"])
		self.surf = pygame.image.load(image).convert_alpha()
		self.rect = self.surf.get_rect(
			center=(random.randint(WIDTH - 20, WIDTH + 100),
					random.randint(0, HEIGHT)))
		self.speed = random.randint(5, 25)

	def update(self):
		# deplacement de l'ennemie
		self.rect.move_ip(-self.speed, 0)
		# si en dehor de l'écran détruit l'OBJ en cour
		if self.rect.right < 0:
			self.kill()
			Ennemy.score += 10
