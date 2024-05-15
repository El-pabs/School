import pygame

pygame.init()


class Projectile(pygame.sprite.Sprite):
    def __init__(self, start_pos, target_pos):
        super().__init__()
        image = pygame.image.load('assets/Graphics/Projectiles/gaz.png').convert_alpha()
        self.image = pygame.transform.scale(image, (50, 50))
        self.rect = self.image.get_rect(center=start_pos)
        self.direction = pygame.Vector2(target_pos) - self.rect.center  # Calculate the direction to the target
        self.direction.normalize_ip()  # Normalize the direction vector
        self.speed = 10

    def update(self):
        self.rect.center += self.direction * self.speed  # Move in the stored direction
        if not pygame.display.get_surface().get_rect().colliderect(self.rect):  # If the firewall is outside the screen
            self.kill()  # Remove the firewall

    def draw(self, surface):
        surface.blit(self.image, self.rect)