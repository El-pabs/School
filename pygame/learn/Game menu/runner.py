import pygame
from sys import exit
from random import randint, choice



class Player(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        player_walk1 = pygame.image.load("img/player/player_walk_1.png").convert_alpha()
        player_walk2 = pygame.image.load("img/player/player_walk_2.png").convert_alpha()
        self.player_walk = [player_walk1, player_walk2]
        self.player_index = 0
        self.player_jump = pygame.image.load("img/player/jump.png").convert_alpha()

        self.image = self.player_walk[self.player_index]
        self.rect = self.image.get_rect(midbottom = (200,300))
        self.gravity = 0

        self.sound_jump = pygame.mixer.Sound('Sound/jump.mp3')

    def player_input(self):
        keys = pygame.key.get_pressed()
        if keys[pygame.K_SPACE] and self.rect.bottom >= 300:
            self.gravity = -20
            self.sound_jump.play()
            self.sound_jump.set_volume(0.1)

    def apply_gravity(self):
        self.gravity += 1
        self.rect.y += self.gravity
        if self.rect.bottom >= 300:
            self.rect.bottom = 300

    def animation_state(self):
        if self.rect.bottom < 300:
            self.image = self.player_jump
        else:
            self.player_index += 0.1
            if self.player_index >= len(player_walk):
                self.player_index = 0
            self.image = player_walk[int(player_index)]
        # play walk animation if the player is on floor

        # display the jump surface when player is not on floor

    def update(self):
        self.player_input()
        self.apply_gravity()
        self.animation_state()

class Obstacle(pygame.sprite.Sprite):
    def __init__(self, type):
        super().__init__()

        if type == "fly":
            fly_frame1 = pygame.image.load('img/fly/fly1.png').convert_alpha()
            fly_frame2 = pygame.image.load('img/fly/fly2.png').convert_alpha()
            self.frames = [fly_frame1, fly_frame2]
            y_pos = 210
        else:
            snail_frame1 = pygame.image.load("img/snail/snail1.png").convert_alpha()
            snail_frame2 = pygame.image.load("img/snail/snail2.png").convert_alpha()
            self.frames = [snail_frame1, snail_frame2]
            y_pos = 300

        self.animation_index = 0
        self.image = self.frames[self.animation_index]
        self.rect = self.image.get_rect(midbottom = ( randint(900,1100), y_pos))

    def animation_states(self):
        self.animation_index += 0.1
        if self.animation_index >= len(self.frames):
            self.animation_index = 0
        self.image = self.frames[int(self.animation_index)]

    def update(self):
        self.animation_states()
        self.rect.x -= 6
        self.destroy()

    def destroy(self):
        if self.rect.x <= -100:
            self.kill()

def display_score():
    current_time = int(pygame.time.get_ticks() /1000) - start_time
    score_surf = test_font.render(f' Score : {current_time}', False, (64,64,64))
    score_rect = score_surf.get_rect(center=(400, 50))
    screen.blit(score_surf,score_rect)
    return current_time

def obstacle_movement(obstacle_list):
    if obstacle_list:
        for obstacle_rect in obstacle_list:
            obstacle_rect.x -= 5

            if obstacle_rect.bottom == 300:
                screen.blit(snail_surf, obstacle_rect)
            else:
                screen.blit(fly_surf, obstacle_rect)

        obstacle_list = [obstacle for obstacle in obstacle_list if obstacle.x > -100]

        return obstacle_list
    else: return []

def collision(player, obstacles):
    if obstacles:
        for obstacle_rect in obstacles:
            if player.colliderect(obstacle_rect):
                return False
    return True

def collision_sprite():
    if pygame.sprite.spritecollide(player.sprite,obstacle_group,False):
        obstacle_group.empty()
        return False
    else:
        return True

def player_animation():
    global player_surf, player_index

    if player_rect.bottom < 300:
        player_surf = player_jump
    else:
        player_index += 0.1
        if player_index >= len(player_walk):
            player_index = 0
        player_surf = player_walk[int(player_index)]
    #play walk animation if the player is on floor

    #display the jump surface when player is not on floor

pygame.init()
screen = pygame.display.set_mode((800,400))
pygame.display.set_caption("Runner")
clock = pygame.time.Clock()
test_font = pygame.font.Font("assets/Pixeltype.ttf", 50)
game_active = False
start_time = 0
score = 0
high_score = 0


#groups
player = pygame.sprite.GroupSingle()
player.add(Player())

obstacle_group = pygame.sprite.Group()



sky_surf = pygame.image.load("img/Sky.png").convert()
ground_surf = pygame.image.load("img/ground.png").convert()

#score_surf = test_font.render("My game", False, (64,64,64))
#score_rect = score_surf.get_rect(center= (400, 50))

#snail
snail_frame1 = pygame.image.load("img/snail/snail1.png").convert_alpha()
snail_frame2 = pygame.image.load("img/snail/snail2.png").convert_alpha()
snail_frames = [snail_frame1, snail_frame2]
snail_frame_index = 0
snail_surf = snail_frames[snail_frame_index]

#fly
fly_frame1 = pygame.image.load('img/fly/fly1.png').convert_alpha()
fly_frame2 = pygame.image.load('img/fly/fly2.png').convert_alpha()
fly_frames = [fly_frame1, fly_frame2]
fly_frame_index = 0
fly_surf = fly_frames[fly_frame_index]

obstacle_rect_list = []

#player

player_walk1 = pygame.image.load("img/player/player_walk_1.png").convert_alpha()
player_walk2 = pygame.image.load("img/player/player_walk_2.png").convert_alpha()
player_walk = [player_walk1, player_walk2]
player_index = 0
player_jump = pygame.image.load("img/player/jump.png").convert_alpha()

player_surf = player_walk[player_index]
player_rect = player_surf.get_rect(midbottom =(80,300))
player_grav = 0

#intro screen
player_stand = pygame.image.load('img/Player/player_stand.png').convert_alpha()
player_stand = pygame.transform.rotozoom(player_stand, 0,2)
player_stand_rect = player_stand.get_rect(center = (400,200))

game_name = test_font.render('Pixel Runner', False, (111, 196,169))
game_name_rect = game_name.get_rect(center = (400,80))

game_message = test_font.render("Press Space to run", False, (111, 196,169))
game_message_rect = game_message.get_rect(center=(400,320))

#timer
obstacle_timer = pygame.USEREVENT +1
pygame.time.set_timer(obstacle_timer, 1500)

snail_animation_timer = pygame.USEREVENT +2
pygame.time.set_timer(snail_animation_timer, 500)

fly_animation_timer = pygame.USEREVENT +2
pygame.time.set_timer(fly_animation_timer, 200)

def reset_game_runner():
    global player, obstacle_group, game_active, start_time, score, current_time
    print ("Resetting the game")  # Debugging line
    # Reset the player's position and gravity
    player.sprite.rect.midbottom = (80, 300)
    player.sprite.gravity = 0

    # Clear all the obstacles
    obstacle_group.empty()

    # Reset the game_active variable and the score
    game_active = False
    start_time = int(pygame.time.get_ticks() / 1000)  # Reset the start time
    score = 0
    current_time = 0
    load_high_score()
def load_high_score():
    global high_score
    try:
        with open('high_score.txt', 'r') as f:
            high_score = int(f.read())
    except FileNotFoundError:
        high_score = 0

def save_high_score():
    with open('high_score.txt', 'w') as f:
        f.write(str(high_score))

def runner_play():
    global game_active, start_time, score, snail_frame_index, fly_frame_index, high_score
    load_high_score()
    game_active = True
    score = 0
    snail_frame_index = 0  # Define snail_frame_index here
    fly_frame_index = 0  # Define fly_frame_index here
    start_time = int(pygame.time.get_ticks() / 1000)  # Start the timer here
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()

            if game_active:
                if event.type == pygame.MOUSEBUTTONDOWN:
                    if player_rect.collidepoint(event.pos):
                        player_grav = -20
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_SPACE and player_rect.bottom >= 300:
                        player_grav = -20

                if event.type == obstacle_timer:
                    obstacle_group.add(Obstacle(choice(['fly', 'snail', 'snail', 'snail'])))
                    print("Spawned a new obstacle")  # Debugging line

            else:
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_SPACE and event.key == pygame.K_SPACE:
                        game_active = True
                        start_time = int(pygame.time.get_ticks() /1000)

                if event.type == obstacle_timer:
                    obstacle_group.add(Obstacle(choice(['fly', 'snail', 'snail', 'snail'])))
                    #if randint(0,2):
                    #    obstacle_rect_list.append(snail_surf.get_rect(bottomright = (randint(900,1100), 300)))
                    #else:
                    #    obstacle_rect_list.append(fly_surf.get_rect(bottomright = (randint(900,1100), 210)))
                if event.type == snail_animation_timer:
                    if snail_frame_index == 0:
                        snail_frame_index = 1
                    else:
                        snail_frame_index = 0
                    snail_surf = snail_frames[snail_frame_index]

                if event.type == fly_animation_timer:
                    if fly_frame_index == 0:
                        fly_frame_index = 1
                    else:
                        fly_frame_index = 0
                    fly_surf = fly_frames[fly_frame_index]





        if game_active:
            screen.blit(sky_surf,(0,0))
            screen.blit(ground_surf, (0,300))
            #pygame.draw.rect(screen, "#c0e8ec",score_rect)
            #pygame.draw.rect(screen, "#c0e8ec",score_rect,10)
            #screen.blit(score_surf,score_rect)
            score = display_score()

            #snail_rect.x -= 4
            #if snail_rect.right < 0:
            #    snail_rect.left = 800
            #screen.blit(snail_surf,snail_rect)

            #player
            #player_grav +=1
            #player_rect.y += player_grav
            #if player_rect.bottom >= 300:
            #    player_rect.bottom = 300
            #player_animation()
            #screen.blit(player_surf,player_rect)
            player.draw(screen)
            player.update()

            obstacle_group.draw(screen)
            obstacle_group.update()

            #obstacle movement
            game_active = collision_sprite()
            #obstacle_rect_list = obstacle_movement(obstacle_rect_list)

            #collision
            #game_active = collision(player_rect, obstacle_rect_list)


        else:
            # screen.fill((94,129,162))
            # screen.blit(player_stand, player_stand_rect)
            # score_message = test_font.render(f'Your score : {score}', False, (111, 196,169))
            # score_message_rect = score_message.get_rect(center= (400,330))
            # screen.blit(game_name, game_name_rect)
            # obstacle_rect_list.clear()
            # player_rect.midbottom = (80,300)
            # player_grav = 0
            #
            # if score == 0:
            #     screen.blit(game_message,game_message_rect)
            # else:
            #     screen.blit(score_message, score_message_rect)
            if score > high_score:
                high_score = score
                save_high_score()  # Save the high score when the game ends
            return f"Score réalisé : {score}, High Score: {high_score}"


        pygame.display.update()
        clock.tick(60)
