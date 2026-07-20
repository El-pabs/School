import pygame

pygame.init()


class Obstacle(pygame.sprite.Sprite):
    '''
    Classe Obstacle qui va créer les bonus et les malus du jeu
    '''
    def __init__(self, image, x, y, effect):
        super().__init__()
        self.image = image
        self.rect = self.image.get_rect(topleft=(x, y))
        self.effect = effect

    def intersects(self, other):
        '''
        Fonction qui vérifie si le joueur touche un bonus ou un malus
        '''
        return self.rect.colliderect(other.rect)

    def draw(self, surface):
        surface.blit(self.image, self.rect)

    def apply_effect(self, hero):
        '''
        Fonction qui applique l'effet du bonus ou du malus sur le joueur
        '''
        if self.effect == 'heal':
            if hero.health < hero.max_health:
                hero.health += 10
                print(f"Hero health: {hero.health}")
        elif self.effect == 'speed':
            hero.speed += 3
            print(f"Hero speed: {hero.speed}")
        elif self.effect == 'shield':
            hero.shield_state = True
            if hero.shield < hero.max_shield:
                hero.shield += 20
                print(f"Hero shield: {hero.shield}")
        elif self.effect == 'rage':
            hero.knife_range += 100
            hero.sword_range += 100
            hero.rage_end_time = pygame.time.get_ticks() + 10000
            print(f"Hero attack range: {hero.knife_range} {hero.sword_range}")
        elif self.effect == 'unheal':
            hero.hurt(10)
            print(f"Hero health: {hero.health}")
