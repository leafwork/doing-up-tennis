function love.load()
    --set up game window
    window_width = 1024
    window_height = 1024
    love.window.setMode(window_width, window_height)
    love.window.setTitle("doing up tennis")
    love.graphics.setDefaultFilter("nearest")

    font_score = love.graphics.newFont(48, "mono")

    --load sounds
    bounce = love.audio.newSource("bounce.wav", "static")
    bounce:setVolume(0.7)
    player_point = love.audio.newSource("player_point.wav", "static")
    player_point:setVolume(0.4)
    enemy_point = love.audio.newSource("enemy_point.wav", "static")
    enemy_point:setVolume(0.4)

    --load court background
    court = love.graphics.newImage("court.png")

    --initalize player paddle
    player_paddle = love.graphics.newImage("paddle.png")
    player_width = player_paddle:getWidth()
    player_height = player_paddle:getHeight()
    player_x = (window_width / 2) - (player_width / 2)
    player_y = window_height - 64 - player_height
    player_speed = 750

    --initalize enemy paddle
    enemy_paddle = love.graphics.newImage("paddle.png")
    enemy_width = enemy_paddle:getWidth()
    enemy_height = enemy_paddle:getHeight()
    enemy_x = (window_width / 2) - (enemy_width / 2)
    enemy_y = 64
    enemy_speed = 200

    --initialize ball
    ball = love.graphics.newImage("ball.png")
    ball_width = ball:getWidth()
    ball_x = (window_width / 2) - (ball_width / 2)
    ball_y = (window_height / 2) + (ball_width / 2)
    ball_xspeed = 0
    ball_speed = 350
    ball_down = true

    --save ball start position (for serves)
    ball_x_start = ball_x
    ball_y_start = ball_y
    ball_xspeed_start = 0

    --initialize scores
    player_score = 0
    enemy_score = 0

    --paddle bounce angle constant
    bounce_angle = 6.5
end



function love.update(dt)
    --handle option inputs
    if love.keyboard.isDown("q") then
        love.event.quit()
    end

    --adjust difficulty (enemy speed)
    if love.keyboard.isDown("1") then
        enemy_speed = 100
    end
    if love.keyboard.isDown("2") then
        enemy_speed = 200
    end
    if love.keyboard.isDown("3") then
        enemy_speed = 300
    end

    --player movement
    if love.keyboard.isDown("left") then
        if player_x > 0 then
            player_x = player_x - player_speed * dt
            if player_x < 0 then
                player_x = 0
            end
        end
    end
    if love.keyboard.isDown("right") then
        if player_x < (window_width - player_width) then
            player_x = player_x + player_speed * dt
            if player_x > (window_width - player_width) then
                player_x = window_width - player_width
            end
        end
    end

    --ball moving toward player
    if ball_down == true then
        ball_y = ball_y + ball_speed * dt
        --check player collision
        if ball_x + ball_width/2 >= player_x
        and ball_x + ball_width/2 <= player_x + player_width
        and ball_y + ball_width >= player_y
        and ball_y + ball_width <= player_y + player_height then
            --player has hit ball
            ball_down = false
            ball_xspeed = (ball_x + ball_width/2 - (player_x + player_width/2)) * bounce_angle
            love.audio.stop(bounce)
            love.audio.play(bounce)
        end
    end

    --ball moving toward enemy
    if ball_down == false then
        ball_y = ball_y - ball_speed * dt
        --check enemy collision
        if ball_x + ball_width/2 >= enemy_x
        and ball_x + ball_width/2 <= enemy_x + enemy_width
        and ball_y <= enemy_y + enemy_height
        and ball_y >= enemy_y then
            --enemy has hit ball
            ball_down = true
            ball_xspeed = (ball_x + ball_width/2 - (enemy_x + enemy_width/2)) * bounce_angle
            love.audio.stop(bounce)
            love.audio.play(bounce)
        end
    end

    ball_x = ball_x + ball_xspeed * dt

    --bounce off walls
    if ball_x <= 0 then
        ball_x = 0
        ball_xspeed = -ball_xspeed
        love.audio.stop(bounce)
        love.audio.play(bounce)
    end
    if ball_x + ball_width >= window_width then
        ball_x = window_width - ball_width
        ball_xspeed = -ball_xspeed
        love.audio.stop(bounce)
        love.audio.play(bounce)
    end

    --keep score
    if ball_y <= 0 then
        player_score = player_score + 1
        --enemy serves
        ball_x = ball_x_start
        ball_y = ball_y_start
        ball_xspeed = ball_xspeed_start
        ball_down = false
        love.audio.play(player_point)
    end

    if ball_y >= window_height - ball_width then
        enemy_score = enemy_score + 1
        --player serves
        ball_x = ball_x_start
        ball_y = ball_y_start
        ball_xspeed = ball_xspeed_start
        ball_down = true
        love.audio.play(enemy_point)
    end

    --chatgpt5 level enemy AI
    if enemy_x + (enemy_width / 2) < ball_x then
        enemy_x = enemy_x + enemy_speed*dt
        if enemy_x + enemy_width > window_width then
            enemy_x = window_width - enemy_width
        end
    end
    if enemy_x + (enemy_width / 2) > ball_x then
        enemy_x = enemy_x - enemy_speed*dt
        if enemy_x < 0 then
            enemy_x = 0
        end
    end


end



function love.draw()
    love.graphics.draw(court, 0, 0)

    love.graphics.draw(player_paddle, player_x, player_y)
    love.graphics.draw(enemy_paddle, enemy_x, enemy_y)
    love.graphics.draw(ball, ball_x, ball_y)

    --display scores
    love.graphics.setFont(font_score)
    love.graphics.print({{0, 0, 0, 255}, enemy_score}, 16, 16)
    love.graphics.print({{0, 0, 0, 255}, player_score}, 16, window_height-66)
end