import pygame

class Movingfloor(pygame.sprite.Sprite):
	def __init__(self, x, y):
		super(Movingfloor, self).__init__()
		self.surf = pygame.image.load("img/cailloux.png").convert_alpha()
		self.rect = self.surf.get_rect(topleft=(x, y))

	def update(self, WIDTH):
		self.rect.move_ip(-10,0)
		if(self.rect.right < 0 ):
			self.rect = self.surf.get_rect(topleft=(WIDTH,0))