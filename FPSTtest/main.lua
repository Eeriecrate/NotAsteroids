function love.load()
	math.randomseed(os.time());
	math_functions = require("math_functions");
	--love.graphics.setColor(math.random(1,255),math.random(1,255),math.random(1,255));
	Options = {};
	Options.curSize = {};
	Options.curSize.X = 800;
	Options.curSize.Y = 600;
	Options.Fullscreen = false;
	gameOver = false;
	Points = 0;
	Booms = {};
	BoomImage = love.graphics.newImage("Boom.png");
	function makeBoom(where)
		local Boom = {};
		Boom.Position = {};
		Boom.Position.X = where.X;
		Boom.Position.Y = where.Y;
		Boom.Size = 0;
		Boom.maxSize = 0.3703703703703704;
		Boom.iteration = 0.003;
		table.insert(Booms,Boom);
	end

	love.graphics.setDefaultFilter("nearest", "nearest");
	Sounds = {};
	Sounds.Pew = love.audio.newSource("Pew.wav","static");
	Ship = {};
	Ship.Image = love.graphics.newImage("Ship.png");
	Ship.Rotation = 0;
	Ship.Size = {};
	Ship.Size.X = 20;
	Ship.Size.Y = 20;
	Ship.Speed = 0;
	Ship.Dead = false;
	Ship.Position = {};
	Ship.Position.X = 400-20;
	Ship.Position.Y = 300-20;
	Ship.offputPosition = {};
	Ship.offputPosition.X = 0;
	Ship.offputPosition.Y = 0;
	Ship.Thrust = false;
	Ship.thrustDirection = 0;
	missleImage = love.graphics.newImage("Missle.png");
	Missles = {};
	canMakeMissle = 0;
	makeMissle = function()
		if canMakeMissle <= 0 then
			canMakeMissle = 30;
			Sounds.Pew:play();
			local Missle = {};
			Missle.Rotation = math.rad(Ship.Rotation);
			Missle.Position = {};
			Missle.Position.X = Ship.Position.X;
			Missle.Position.Y = Ship.Position.Y;
			Missle.Speed = 10;
			table.insert(Missles,Missle);
			function Missle.isTouching(x)
				return (math.abs((x.Position.X - (Missle.Position.X)))<=((135*.25)*.5)) and (math.abs((x.Position.Y - (Missle.Position.Y)))<=((135*.25)*.5));
			end
		end
	end

	UFO = {};
	UFO.Image = love.graphics.newImage("NotUFO.png");
	UFO.Active = false;
	UFO.Redirect = 90;
	UFO.coolDown = 45;
	UFO.missleCool = 180;
	UFO.Position = {};
	UFO.Position.X = 0;
	UFO.Position.Y = 0;
	UFO.Rotation = 0;
	UFO.Speed = 2.5;
	UFO.Missles = {};
	UFO.RedirectUFO = function()
		UFO.Redirect = 90;
		UFO.Rotation = math_functions.getAngleTo(math_functions.packageLocation(UFO.Position.X,UFO.Position.Y),math_functions.packageLocation(Ship.Position.X,Ship.Position.Y));
	end
	UFO.Shoot = function()
		UFO.missleCool = 90;
		local Missle = {};
		Missle.Position = {};
		Missle.Position.X = UFO.Position.X+((135*.25)*.5);
		Missle.Position.Y = UFO.Position.Y+((135*.25)*.5);
		Missle.Rotation = math_functions.getAngleTo(math_functions.packageLocation(Missle.Position.X,Missle.Position.Y),math_functions.packageLocation(Ship.Position.X,Ship.Position.Y));
		Missle.Speed = 5;
		function Missle.isTouching(x)
				return (math.abs((x.Position.X - (Missle.Position.X)))<=(10) and (math.abs((x.Position.Y - (Missle.Position.Y)))<=(10)));
			end
		table.insert(UFO.Missles,Missle);
	end

	Asteroids = {};
	canMakeAsteroid = 90;
	asteroidImage = love.graphics.newImage("Asteroid.png");

	makeRubble = function(ast)
		for i = 1,2,1 do
			print(i)
			local Rubble = {};
			Rubble.Position = {};
			Rubble.Position.X = ast.Position.X;
			Rubble.Position.Y = ast.Position.Y;
			Rubble.Rotation = ast.Rotation + math.rad(math.random(-45,45));
			Rubble.Speed = 2; 				
			Rubble.Size = ast.Size/2;
			function Rubble.isTouching(x)
				return (math.abs((x.Position.X - (Rubble.Position.X)))<=(Rubble.Size*12)) and (math.abs((x.Position.Y - (Rubble.Position.Y)))<=(Rubble.Size*12));
			end			
			table.insert(Asteroids,Rubble);
		end
	end


	makeAsteroid = function()
		if canMakeAsteroid <= 0 then
			canMakeAsteroid = 90;
			local Asteroid = {};
			Asteroid.Position = {};
			Asteroid.Speed = 2; 	
			Asteroid.Entrance = math.random(1,4);
			Asteroid.Size = math.random(1,3);
			if Asteroid.Entrance == 1 then
				Asteroid.Rotation = math.rad(math.random(-45,45));
				Asteroid.Position.X = -25*Asteroid.Size;
				Asteroid.Position.Y = math.random(0,600);
			elseif Asteroid.Entrance == 2 then
				Asteroid.Rotation = math.rad(math.random(45,135));
				Asteroid.Position.Y = -25*Asteroid.Size;
				Asteroid.Position.X = math.random(0,800);
			elseif Asteroid.Entrance == 3 then
				Asteroid.Rotation = math.rad(math.random(135,235));
				Asteroid.Position.X = 900-(-25*Asteroid.Size);
				Asteroid.Position.Y = math.random(0,600);
			elseif Asteroid.Entrance == 4 then
				Asteroid.Rotation = math.rad(math.random(-135,-45));
				Asteroid.Position.Y = 700-(-25*Asteroid.Size);
				Asteroid.Position.X = math.random(0,800);
			end

			function Asteroid.isTouching(x)
				return (math.abs((x.Position.X - (Asteroid.Position.X)))<=(Asteroid.Size*12)) and (math.abs((x.Position.Y - (Asteroid.Position.Y)))<=(Asteroid.Size*12));
			end
			table.insert(Asteroids,Asteroid);
			return Asteroid;
		end
	end
end

function love.update(dt)
	if not gameOver then
		makeAsteroid();
		UFO.coolDown = UFO.coolDown - 1;
		UFO.missleCool = UFO.missleCool - 1;
		UFO.Redirect = UFO.Redirect - 1;
		if not(UFO.Active) and UFO.coolDown <= 0 then
			UFO.Active = true;
			UFO.missleCool = 90;
			UFO.Redirect = 45;
			local Top = math.random(1,2);
			if Top == 1 then
				UFO.Position.Y = -60;
			else
				UFO.Position.Y = 660;
			end
			UFO.Position.X = math.random(0,800);
			UFO.RedirectUFO();
		elseif UFO.Active then
			if UFO.missleCool == 0 then
				UFO.Shoot();
			end
				UFO.Position.X = UFO.Position.X + math.cos(UFO.Rotation) * UFO.Speed;
				UFO.Position.Y = UFO.Position.Y + math.sin(UFO.Rotation) * UFO.Speed;
			if UFO.Position.X >= 750 or UFO.Position.X <= 50 or UFO.Position.Y >= 550 or UFO.Position.Y <= 50 then
				UFO.RedirectUFO();
			end
		end
		for i,v in pairs(UFO.Missles) do
			v.Position.X = v.Position.X + math.cos(v.Rotation) * v.Speed;
			v.Position.Y = v.Position.Y + math.sin(v.Rotation) * v.Speed;
			if v.Position.X >= 900 or v.Position.X <= -100 or v.Position.Y <= -100 or v.Position.Y >= 700 then
				table.remove(UFO.Missles,i);
			end
			if v.isTouching(Ship) then
				gameOver = true;
				Missles = {};
				Asteroids = {};
				UFO.Active = false;
				UFO.Missles = {};
				makeBoom(Ship.Position);
				Ship.Dead = true;
			end
		end
		--love.window.setMode( Options.curSize.X, Options.curSize.Y, {resizable=true, vsync=false, fullscreen=false,minwidth=800,minheight=600});
		for i,v in pairs(Asteroids) do
			v.Position.X = v.Position.X + math.cos((v.Rotation)) * v.Speed;
			v.Position.Y = v.Position.Y + math.sin((v.Rotation)) * v.Speed;
			if v.Position.X >= 1050 or v.Position.X <= -350 or v.Position.Y <= -350 or v.Position.Y >= 950 then
				table.remove(Asteroids,i);
			else
				for x,mi in pairs(Missles) do
					if v.isTouching(mi) then
						table.remove(Missles,x);
						makeRubble(v);
						Points = Points + 100/v.Size;
						table.remove(Asteroids,i);
					end
				end
				if v.isTouching(UFO) and (UFO.Active) then
					UFO.Active = false;
					UFO.coolDown = 300;
					makeBoom(UFO.Position);
					Points = Points + 125;
				end
				if v.isTouching(Ship) then
					gameOver = true;
					Missles = {};
					Asteroids = {};
					UFO.Active = false;
					UFO.Missles = {};
					makeBoom(Ship.Position);
					Ship.Dead = true;
				end
			end
		end
		canMakeAsteroid = canMakeAsteroid - 1;
		canMakeMissle = canMakeMissle - 1;
		for i,v in pairs(Missles) do
			v.Position.X = v.Position.X + math.cos(v.Rotation) * v.Speed;
			v.Position.Y = v.Position.Y + math.sin(v.Rotation) * v.Speed;
			if v.isTouching(UFO) and UFO.Active then
				UFO.Active = false;
				UFO.coolDown = 300;
				makeBoom(UFO.Position);
				Points = Points + 250
			end
			if v.Position.X >= 900 or v.Position.X <= -100 or v.Position.Y <= -100 or v.Position.Y >= 700 then
				table.remove(Missles,i);
			end
		end
		if love.keyboard.isDown(" ") then
			makeMissle();
		end
		if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
			Ship.Rotation = Ship.Rotation - 5;
		elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
			Ship.Rotation = Ship.Rotation + 5;
		end
		if not(love.keyboard.isDown("w") or love.keyboard.isDown("up")) and not Ship.Thrust and Ship.Speed ~= 0 then
			Ship.Speed = Ship.Speed - (5/60);
			if Ship.Speed < 0 then
				Ship.Speed = 0;
			end
		end
		if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
			Ship.thrustDirection = math.rad(Ship.Rotation);
			Ship.Speed = 5;
			Ship.Thrust = true;
		else Ship.Thrust = false;
		end
		if not (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and Ship.Speed <= 0 then
			Ship.Speed = 0;
			Ship.Thrust = false;
		end
		if Ship.Speed ~= 0 then
			Ship.Position.X = Ship.Position.X + math.cos(Ship.thrustDirection) * Ship.Speed;
			Ship.Position.Y = Ship.Position.Y + math.sin(Ship.thrustDirection) * Ship.Speed;
		end
		if Ship.Position.X > 820 then
			Ship.Position.X = -15;
		elseif Ship.Position.X < -20 then
			Ship.Position.X = 815
		end
		if Ship.Position.Y > 620 then
			Ship.Position.Y = -15;
		elseif Ship.Position.Y < -20 then
			Ship.Position.Y = 615;
		end
	end
end

function love.keyreleased(key)
	if key == " " then
		Ship.Thrust = false;
	end
end

function love.draw()
	love.graphics.print(math.floor(Points));
	for i,v in pairs(Booms) do
		if v.Size >= v.maxSize then
			table.remove(Booms,i);
		else
			v.Size = v.Size + v.iteration;
		end
		love.graphics.draw(BoomImage,v.Position.X-((v.Size*135)*.5),v.Position.Y-((v.Size*135)*.5),0,v.Size,v.Size);
	end
	for i,v in pairs(Asteroids) do
		love.graphics.draw(asteroidImage,v.Position.X,v.Position.Y,math.rad(v.Rotation),v.Size,v.Size,(6.25)*v.Size,(6.25)*v.Size);
	end
	for i,v in pairs(Missles) do
		love.graphics.draw(missleImage,v.Position.X,v.Position.Y,math.rad(v.Rotation),1,1,2.5,2.5)
	end
	love.graphics.setColor(255,0,0,255);
	for i,v in pairs(UFO.Missles) do
		love.graphics.draw(missleImage,v.Position.X,v.Position.Y,math.rad(v.Rotation),1,1,2.5,2.5)
	end
	love.graphics.setColor(255,255,255,255);
	if UFO.Active then
		love.graphics.draw(UFO.Image,UFO.Position.X,UFO.Position.Y,0,.25,.25,(135*.25)*.25,(135*.25)*.25);
	end
	if not Ship.Dead then
		love.graphics.draw(Ship.Image,Ship.Position.X,Ship.Position.Y,math.rad(Ship.Rotation),(20/256),(20/256),120,120)
	end
end