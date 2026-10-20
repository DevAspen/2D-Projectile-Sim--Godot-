extends RigidBody2D

@onready var bullet_collider: CollisionPolygon2D = $BulletCollider
@onready var bullet_mesh: Polygon2D = $BulletCollider/BulletMesh
@onready var gravity_vector: Line2D = $GravityVector

@export var bulletMass: float = 0.274
@export var radiusInches: float = 0.75
@export var initialVelocity: int = 1214
@export var dragCoefficient: float = 0.5
@export var airDensity: float = 1.255
@export var gravityAcceleration: float = 9.40
@export var initialAngle: float = 0
@export var initialHeight: float = 0
@export var targetVelocity: float = 10
@export var targetHeight: float = 0

var GRAVITY_FORCE: float = gravityAcceleration * bulletMass

var crossSectionalArea = (radiusInches * 2.54 / 100)**2 * PI
#var kValue = (airDensity * dragCoefficient * crossSectionalArea) / (2 * bulletMass) 

var angle: float = initialAngle * PI/180
var velocity: float = initialVelocity
var velocity_x: float = velocity * cos(angle)
var velocity_y: float = velocity * sin(angle)
var dragForce: float = 0.5 * airDensity * (velocity)**2 * dragCoefficient * crossSectionalArea
var f_dx: float = dragForce * sin(angle)
var f_dy: float = dragForce * -cos(angle)
var f_y: float = f_dy - GRAVITY_FORCE
var a_y: float = f_y / bulletMass
var a_x: float = f_dx / bulletMass

var distance_x: float = 0
var distance_y: float = initialHeight
var time: float = 0

var lastVelocity_y: float = velocity_y

var simulating: bool = true
var stop: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialHeight = abs(initialHeight)
	self.mass = bulletMass
	self.gravity_scale = 0 #9.81 / gravityAcceleration
	distance_y = initialHeight
	bullet_collider.rotation = initialAngle * -PI/180
	angle = initialAngle * PI/180
	velocity_x = velocity * cos(angle)
	velocity_y = velocity * sin(angle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (simulating):
		dragForce = 0.5 * airDensity * (velocity)**2 * dragCoefficient * crossSectionalArea
		f_dx = -dragForce * cos(angle) #if (angle != 0) else dragForce
		f_dy = -dragForce * sin(angle) #if (angle > 0) else dragForce * sin(angle)
		f_y = f_dy - GRAVITY_FORCE
		a_y = f_y / bulletMass
		a_x = f_dx / bulletMass
		velocity_x += (a_x * delta)
		velocity_y += (a_y * delta)
		print(str(snapped(velocity_y, 0.01)) + ' ; ' + str(snapped(a_y, 0.01)))
		velocity = (velocity_x**2 + velocity_y**2)**0.5
		
		distance_x += (velocity_x * delta)
		distance_y += (velocity_y * delta)
		
		time += delta
		
		if (velocity_x <= targetVelocity or (initialHeight != 0 and distance_y <= targetHeight) or (angle > 0 and (lastVelocity_y >= 0 and velocity_y < 0))):
			stop = true
		
		lastVelocity_y = velocity_y
		
	if (stop and simulating):
		simulating = false
		print('X distance was ' + str(snapped(distance_x, 0.01)) + ' meters')
		print('Y distance was ' + str(snapped(distance_y, 0.01)) + ' meters')
		print('Final x velocity was ' + str(snapped(velocity_x, 0.01)) + ' m/s')
		print('Final y velocity was ' + str(snapped(velocity_y, 0.01)) + ' m/s')
		print('Final combined velocity was ' + str(snapped((velocity_x**2 + velocity_y**2)**0.5, 0.01)) + ' m/s')
		print('Air time was ' + str(snapped(time, 0.01)) + ' seconds')
		bullet_mesh.color = Color.RED
