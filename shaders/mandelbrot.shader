shader_type canvas_item;
render_mode unshaded;


// UNIFORM VARIABLES

uniform highp float scale;
uniform float rotation;
uniform float shear;
uniform float divergence_limit;
uniform int convergence_iter_limit;
uniform vec2 center;
uniform float branch_factor;

uniform sampler2D palette;
uniform float palette_index;
uniform float hue;
uniform float saturation;
uniform float brightness_factor;
uniform float alpha;


// VARYINGS

varying flat mat3 transform;


// HELPER METHODS

mat3 rotated(float a)
{
	// This method returns a 3x3 matrix that represents a 2D rotation transformation
	float c, s;
	c = cos(a);
	s = sin(a);
	return mat3(vec3(c, s, 0), vec3(-s, c, 0), vec3(0, 0, 1));
}

mat3 scaled(float s)
{
	// This method returns a 3x3 matrix that represents a 2D scale transformation
	return mat3(vec3(s, 0, 0), vec3(0, s, 0), vec3(0, 0, 1));
}

mat3 translated(vec2 t)
{
	// This method returns a 3x3 matrix that represents a 2D translation transformation
	return mat3(vec3(1, 0, 0), vec3(0, 1, 0), vec3(t.x, t.y, 1));
}

mat3 sheared(float sh)
{
	// This function returns a 3x3 matrix that represents a 2D shearing transformation on the imaginary axis (y)
	return mat3(vec3(1, sh, 0), vec3(0, 1, 0), vec3(0, 0, 1));
}

float brightness(vec3 color)
{
	// Returns the brightness of a given color in RGB format
	return max(color.r, max(color.g, color.b));
}

vec3 hsv2rgb(vec3 c)
{
	// Given the components HSV of a color, returns its RGB components in a 3D-vector
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


// VERTEX SHADER
void vertex()
{
	// This transformation will be applied to each pixel and we calculate it here
	// and pass it to the fragment shader flattened (without interpolation)
	
	transform = translated(-center) * scaled(scale) * rotated(rotation);
	transform *= sheared(shear);
	transform *= translated(vec2(-0.5, -0.5));
}


// FRAGMENT SHADER
void fragment()
{
	// Compute fractal
	highp vec2 a = (transform * vec3(UV, 1.0)).xy;
	highp vec2 b = a;
	int k;
	for(k = 0; k < convergence_iter_limit; k++)
	{
		highp float l = length(b);
		highp float r = pow(l, branch_factor);
		highp float o = atan(b.y, b.x) * branch_factor;
		b = r * vec2(cos(o), sin(o)) + a;
		
		if(l > divergence_limit)
			break;
	}
	
	// Calculate the color brightness for this pixel checking if the point is inside
	// the mandelbrot's set and depending on the number of iterations needed
	
	float r;
	if(k < convergence_iter_limit)
		r = float(k) / float(convergence_iter_limit);
	else
		r = 0.0;
	float v = min(brightness_factor * brightness(texture(palette, vec2(r, 0.0)).xyz), 1.0);

	// Compute the final color for the pixel
	vec3 color = hsv2rgb(vec3(hue, saturation, v));
	COLOR = vec4(color, alpha);
}