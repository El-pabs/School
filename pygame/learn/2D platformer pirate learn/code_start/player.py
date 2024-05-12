from settings import *
from timer import Timer

class Player(pygame.sprite.Sprite):
	def __init__(self, pos, groups, collision_sprites):
		super().__init__(groups)
		self.image = pygame.Surface((48,56))
		self.image.fill('red')

		#rects
		self.rect = self.image.get_frect(topleft = pos)
		self.old_rect = self.rect.copy()

		# movement
		self.direction = vector()
		self.speed = 200
		self.gravity = 1300
		self.jump = False
		self.jump_height = 900

		#collision
		self.collision_sprites = collision_sprites
		self.on_surface = {'floor': False, 'left': False, 'right': False}

		#timers
		self.timers = {
			'wall jump': Timer(2000)
		}

	def input(self):
		keys = pygame.key.get_pressed()
		input_vector = vector(0,0)
		if keys[pygame.K_RIGHT]:
			input_vector.x += 1
		if keys[pygame.K_LEFT]:
			input_vector.x -= 1
		self.direction.x = input_vector.normalize().x if input_vector else input_vector.x

		if keys[pygame.K_SPACE]:
			self.jump = True


	def move(self, dt):
		# horizontal movement

		self.rect.x += self.direction.x * self.speed * dt
		self.collision('horizontal')

		# vertical movement
		if not self.on_surface['floor'] and any((self.on_surface['left'], self.on_surface['right'])):
			self.direction.y = 0
			self.rect.y += self.gravity / 10 * dt

		else:
			self.direction.y += self.gravity / 2 * dt
			self.rect.y += self.direction.y * dt
			self.direction.y += self.gravity / 2 * dt


		# jump
		if self.jump:
			if self.on_surface['floor']:
				print('jump')
				self.direction.y = -self.jump_height
				print('Jump initiated, position:', self.rect.topleft, 'direction.y:',self.direction.y)  # add print statement here
			elif any((self.on_surface['left'], self.on_surface['right'])):
				self.timers['wall jump'].activate()
				self.direction.y = -self.jump_height
				self.direction.x = 1 if self.on_surface['left'] else -1
			self.jump = False  # reset jump variable after a jump is executed

		self.collision('vertical')

	def check_contact(self):
		floor_rect = pygame.Rect(self.rect.bottomleft,(self.rect.width,2))
		right_rect = pygame.Rect(self.rect.topright + vector(0,self.rect.height /4), (2,self.rect.height/2))
		left_rect = pygame.Rect(self.rect.topleft + vector(-2, self.rect.height /4), (2,self.rect.height/2))
		collide_rects = [sprite.rect for sprite in self.collision_sprites]

		#collisions
		self.on_surface['floor'] = True if floor_rect.collidelist(collide_rects) >= 0 else False
		self.on_surface['right'] = True if right_rect.collidelist(collide_rects) >= 0 else False
		self.on_surface['left'] = True if left_rect.collidelist(collide_rects) >= 0 else False


	def collision(self,axis):
		for sprite in self.collision_sprites:
			if sprite.rect.colliderect(self.rect):
				if axis == 'horizontal':
					# left collision
					if self.rect.left <= sprite.rect.right and self.old_rect.left >= sprite.rect.right:
						self.rect.left = sprite.rect.right
					# right collision
					if self.rect.right >= sprite.rect.left and self.old_rect.right <= sprite.rect.left:
						self.rect.right = sprite.rect.left
				else: #vertical
					# top collision
					if self.rect.top <= sprite.rect.bottom and self.old_rect.top >= sprite.rect.bottom:
						self.rect.top = sprite.rect.bottom
					# bottom collision
					if self.rect.bottom >= sprite.rect.top and self.old_rect.bottom <= sprite.rect.top:
						self.rect.bottom = sprite.rect.top
					self.direction.y = 0

	def update_timers(self):
		for timers in self.timers.values():
			timers.update()

	def update(self, dt):
		self.old_rect = self.rect.copy()
		self.update_timers()
		self.input()
		self.move(dt)
		self.check_contact()
