/*-----------------------------------------------------------------------------
 
 Texture.cpp
 
 2009 Shamus Young
 
 -------------------------------------------------------------------------------
 
 This procedurally builds all of the textures.  
 
 I apologize in advance for the apalling state of this module. It's the victim 
 of iterative and experimental development.  It has cruft, poorly named
 functions, obscure code, poorly named variables, and is badly organized. Even
 the formatting sucks in places. Its only saving grace is that it works.
 
 -----------------------------------------------------------------------------*/


#import <stdlib.h>
#import <stdio.h>
#import <math.h>
#import <memory.h>
#import <vector>
using std::vector;

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "gltypes.h"
#import "building.h"
#import "camera.h"
#import "car.h"
#import "light.h"
#import "macro.h"
#import "random.h"
#import "render.h"
#import "sky.h"
#import "texture.h"
#import "world.h"
#import "win.h"
#import "PWGL.h"
#import "RenderAPI.h"
#import "Mathx.h"

inline float randomColorShift(void) { return ((float)(RandomLongR(10)) / 50.0f); }
inline float randomColorVal(void)   { return ((float)(RandomLongR(256)) / 256.0f); }

class CTexture
{
public:
	TextureType       _texType;
	unsigned          _glid;
	int               _desired_size;
	int               _size;
	int               _half;
	int               _segment_size;
	bool              _ready;
	bool              _masked;
	bool              _mipmap;
	bool              _clamp;
public:
	CTexture*         _next;
	CTexture (TextureType _id, int size, bool mipmap, bool clamp, bool masked);
	void              Clear () { _ready = false; }
	void              Rebuild ();
	void              DrawWindows ();
	void              DrawSky ();
	void              DrawHeadlight ();
};

static CTexture*    head = NULL;
static bool         textures_done = false;
static int          build_time = 0;

/*-----------------------------------------------------------------------------
 
 -----------------------------------------------------------------------------*/

void drawrect_simple (int left, int top, int right, int bottom, GLrgba color)
{
	glColor3(color);
	{	MakePrimitive mp(GL_QUADS);
		glVertex2i (left, top);
		glVertex2i (right, top);
		glVertex2i (right, bottom);
		glVertex2i (left, bottom);
	}
}


/*-----------------------------------------------------------------------------
 
 -----------------------------------------------------------------------------*/

void drawrect_simple (int left, int top, int right, int bottom, GLrgba color1, GLrgba color2)
{
	glColor3(color1);
	{	MakePrimitive mp(GL_TRIANGLE_FAN);
		glVertex2i ((left + right) / 2, (top + bottom) / 2);
		glColor3(color2);
		glVertex2i (left, top);
		glVertex2i (right, top);
		glVertex2i (right, bottom);
		glVertex2i (left, bottom);
		glVertex2i (left, top);
	}
}


/*-----------------------------------------------------------------------------
 
 -----------------------------------------------------------------------------*/

void drawrect (int left, int top, int right, int bottom, GLrgba color)
{	
	pwDisable(GL_CULL_FACE);
	pwBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	pwEnable(GL_BLEND);
	pwLineWidth(1.0f);
	pwPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glColor3(color);
	
	glReportError("drawrect setup done.");

	// Try and clear any existing errors out of the system before loading the textures.
	glBegin(GL_POINTS);
	glEnd();

	while(glGetError() != GL_NO_ERROR)
	{
	}
	
	if (left == right) { //in low resolution, a "rect" might be 1 pixel wide
		{	MakePrimitive mp(GL_LINES);
			glVertex2i(left, top);
			glVertex2i(left, bottom);
		}
	} 
	if (top == bottom) { //in low resolution, a "rect" might be 1 pixel wide
		{	MakePrimitive mp(GL_LINES);
			glVertex2i(left, top);
			glVertex2i(right, top);
		}
	} 
	else { // draw one of those fancy 2-dimensional rectangles
		{	MakePrimitive mp(GL_QUADS);
			glVertex2i(left, top);
			glVertex2i(right, top);
			glVertex2i(right, bottom);
			glVertex2i(left, bottom);
		}
		
		float average   = (color.red() + color.blue() + color.green()) / 3.0f;
		int   potential = (int)(average * 255.0f);
		
		if (average > 0.5f) {
			pwBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			{	MakePrimitive mp(GL_POINTS);
				for(int i = left + 1; i < right - 1; i++) {
					for(int j = top + 1; j < bottom - 1; j++) {
						glColor4i(255, 0, RandomIntR(potential), 255);
						float hue = 0.2f + (float)RandomLongR(100) / 300.0f + (float)RandomLongR(100) / 300.0f + (float)RandomLongR(100) / 300.0f;
						GLrgba color_noise = glRgbaFromHsl(hue, 0.3f, 0.5f).colorWithAlpha(float(RandomLongR(potential)) / 144.0f);
						glColor4f(randomColorVal(), randomColorVal(), randomColorVal(), float(RandomLongR(potential)) / 144.0f);
						glColor4(color_noise);
						glVertex2i(i, j);
					}
				}
			}
		}
		int hght = (bottom - top) + (RandomIntR(3) - 1) + (RandomIntR(3) - 1);
		for (int i = left; i < right; i++) {
			if (RandomLongR(6) == 0) {
				hght = bottom - top;
				hght = RandomIntR(hght);
				hght = RandomIntR(hght);
				hght = RandomIntR(hght);
				hght = ((bottom - top) + hght) / 2;
			}
			for (int j = 0; j < 1; j++) {
                MakePrimitive mp(GL_LINES);
                glColor4f(0, 0, 0, (float)RandomLongR(256) / 256.0f);
                glVertex2i(i, bottom - hght);
                glColor4f(0, 0, 0, (float)RandomLongR(256) / 256.0f);
                glVertex2i(i, bottom);
			}
		}
	}
}

/*-----------------------------------------------------------------------------
 
 -----------------------------------------------------------------------------*/

static void window (int x, int y, int size, TextureType tt, GLrgba color)
{
	int margin = size / 3, half = size / 2, i = 0;
	switch (tt) {
		case TEXTURE_BUILDING1: //filled, 1-pixel frame
			drawrect (x + 1, y + 1, x + size - 1, y + size - 1, color);
			break;
		case TEXTURE_BUILDING2: //vertical
			drawrect (x + margin, y + 1, x + size - margin, y + size - 1, color);
			break;
		case TEXTURE_BUILDING3: //side-by-side pair
			drawrect (x + 1, y + 1, x + half - 1, y + size - margin, color);
			drawrect (x + half + 1, y + 1, x + size - 1, y + size - margin,  color);
			break;
		case TEXTURE_BUILDING4: //windows with blinds
			drawrect (x + 1, y + 1, x + size - 1, y + size - 1, color);
			i = RandomIntR(size - 2);
			drawrect (x + 1, y + 1, x + size - 1, y + i + 1, color * 0.3f);
			break;
		case TEXTURE_BUILDING5: //vert stripes
			drawrect (x + 1, y + 1, x + size - 1, y + size - 1, color);
			drawrect (x + margin, y + 1, x + margin, y + size - 1, color * 0.7f);
			drawrect (x + size - margin - 1, y + 1, x + size - margin - 1, y + size - 1, color * 0.3f);
			break;
		case TEXTURE_BUILDING6: //wide horz line
			drawrect (x + 1, y + 1, x + size - 1, y + size - margin, color);
			break;
		case TEXTURE_BUILDING7: //4-pane
			drawrect (x + 2, y + 1, x + size - 1, y + size - 1, color);
			drawrect (x + 2, y + half, x + size - 1, y + half, color * 0.2f);
			drawrect (x + half, y + 1, x + half, y + size - 1, color * 0.2f);
			break;
		case TEXTURE_BUILDING8: // Single narrow window
			drawrect (x + half - 1, y + 1, x + half + 1, y + size - margin, color);
			break;
		case TEXTURE_BUILDING9: //horizontal
			drawrect (x + 1, y + margin, x + size - 1, y + size - margin - 1, color);
			break;
        default:
            break;
	}
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

static void do_bloom(CTexture* t, bool showFlat)
{
	pwBindTexture(GL_TEXTURE_2D, 0);		
	pwViewport(0, 0, t->_size , t->_size);
	pwCullFace (GL_BACK);
	pwBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	pwDepthMask (GL_TRUE);
	pwPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	pwEnable(GL_DEPTH_TEST);
	pwEnable (GL_CULL_FACE);
	pwCullFace (GL_BACK);
	pwBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	pwEnable (GL_FOG);
	pwFogf (GL_FOG_START, RenderFogDistance () / 2);
	pwFogf (GL_FOG_END, RenderFogDistance ());
	pwPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	pwClearColor (0.0f, 0.0f, 0.0f, 0.0f);
	pwClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	pwEnable (GL_TEXTURE_2D);
	EntityRender(showFlat);
	CarRender ();
	LightRender ();
	pwBindTexture(GL_TEXTURE_2D, t->_glid);		
	pwTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	pwCopyTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, t->_size, t->_size, 0);
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

CTexture::CTexture (TextureType texType, int size, bool mipmap, bool clamp, bool masked)
{
	glGenTextures (1, &_glid); 
	_texType = texType;
	_mipmap = mipmap;
	_clamp = clamp;
	_masked = masked;
	_desired_size = size;
	_size = size;
	_half = size / 2;
	_segment_size = size / SEGMENTS_PER_TEXTURE;
	_ready = false;
	_next = head;
	head = this;
}

/*-----------------------------------------------------------------------------
 
 This draws all of the windows on a building texture. lit_density controls 
 how many lights are on. (1 in n chance that the light is on. Higher values 
 mean less lit windows. run_length controls how often it will consider 
 changing the lit / unlit status. 1 produces a complete scatter, higher
 numbers make long strings of lights.
 
 -----------------------------------------------------------------------------*/

void CTexture::DrawWindows ()
{
	int         x, y;
	int         run;
	int         run_length;
	int         lit_density;
	GLrgba      color;
	bool        lit;
	
	glReportError("CTexture::DrawWindows BEGIN");
	
	//color = glRgbaUnique (_my_id);
	for (y = 0; y < SEGMENTS_PER_TEXTURE; y++)  {
		//Every few floors we change the behavior
		if (!(y % 8)) {
			run = 0;
			run_length = RandomIntR(9) + 2;
			lit_density = 2 + RandomIntR(2) + RandomIntR(2);
			lit = false;
		}
		for (x = 0; x < SEGMENTS_PER_TEXTURE; x++) {
			//if this run is over reroll lit and start a new one
			if (run < 1) {
				run = RandomIntR(run_length);
				lit = RandomLongR(lit_density) == 0;
				//if (lit)
				//color = GLrgba (0.5f + (float)(RandomLong () % 128) / 256.0f) + GLrgba (RANDOM_COLOR_SHIFT, RANDOM_COLOR_SHIFT, RANDOM_COLOR_SHIFT);
			}
			if (lit) 
				color = GLrgba(0.5f + (float)(RandomLong() % 128) / 256.0f) + GLrgba(randomColorShift(), randomColorShift(), randomColorShift());
			else 
				color = GLrgba ((float)(RandomLong () % 40) / 256.0f);
			window (x * _segment_size, y * _segment_size, _segment_size, _texType, color);
			run--;
			
		}
	}
	glReportError("CTexture::DrawWindows END");
}


/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

static void drawOneCloud(int x, int y, int width, int height, GLfloat scale, int offset)
{
    float inv_scale = 1.0f - (scale);
    GLrgba color = (scale < 0.4f) ? WorldBloomColor() * 0.1f : GLrgba(0.0f);
    color = color.colorWithAlpha(0.2f);
    glColor4(color);
    int width_adjust = int(float(width) / 2.0f + int(inv_scale * (float(width) / 2.0f)));
    int height_adjust = height + int(scale * float(height) * 0.99f);
    glTexCoord2f(0, 0);   glVertex2i(offset + x - width_adjust, y + height - height_adjust);
    glTexCoord2f(0, 1);   glVertex2i(offset + x - width_adjust, y + height);
    glTexCoord2f(1, 1);   glVertex2i(offset + x + width_adjust, y + height);
    glTexCoord2f(1, 0);   glVertex2i(offset + x + width_adjust, y + height - height_adjust);
}


void CTexture::DrawSky ()
{
	GLrgba color = WorldBloomColor();
	float grey = (color.red() + color.green() + color.blue()) / 3.0f;
	color = (color + GLrgba(grey) * 2.0f) / 15.0f;    //desaturate, slightly dim
	pwDisable (GL_BLEND);
	
	{
        MakePrimitive mp(GL_QUAD_STRIP);
		glColor3f(0,0,0);
		glVertex2i(0, _half);
		glVertex2i(_size, _half);
		glColor3(color);
		glVertex2i(0, _size - 2);  
		glVertex2i(_size, _size - 2);  
	}
	
	//Draw a bunch of little faux-buildings on the horizon.
	for (int i = 0; i < _size; i += 5)
		drawrect (i, _size - RandomIntR(8) - RandomIntR(8) - RandomIntR(8), i + RandomIntR(9), _size, GLrgba(0.0f));
	
	//Draw the clouds
	for (int i = _size - 30; i > 5; i -= 2) {
		int x     = RandomIntR(_size), y = i;
		int scale = 1.0f - (float(y) / float(_size));
		int width = RandomIntR(_half / 2) + int(float(_half) * scale) / 2;
		int hght  = std::max(int(float(width) * scale), 4);
		
		pwEnable (GL_BLEND);
		pwBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		pwDisable (GL_CULL_FACE);
		pwEnable (GL_TEXTURE_2D);
		pwBindTexture (GL_TEXTURE_2D, TextureId (TEXTURE_SOFT_CIRCLE));
		pwDepthMask (GL_FALSE);
		
        MakePrimitive mp(GL_QUADS);
        for (int offset = -_size; offset <= _size; offset += _size)
            for (int scale = 1.0f; scale > 0.0f; scale -= 0.25f)
                drawOneCloud(x, y, width, hght, scale, offset);
	}
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

void CTexture::DrawHeadlight ()
{
	//Make a simple circle of light, bright in the center and fading out	
	float           radius = float(_half) - 20;
	int             i, x = _half - 20, y = _half;
	GLvector2       pos;

	pwEnable (GL_BLEND);
	pwBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
    {
    	MakePrimitive mp(GL_TRIANGLE_FAN);
		glColor4f (0.8f, 0.8f, 0.8f, 0.6f);
		glVertex2i (_half - 5, y);
		glColor4f (0, 0, 0, 0);
		for (i = 0; i <= 360; i += 36) {
			pos.x = sinf ((float)(i % 360) * DEGREES_TO_RADIANS) * radius;
			pos.y = cosf ((float)(i % 360) * DEGREES_TO_RADIANS) * radius;
			glVertex2i (x + (int)pos.x, _half + (int)pos.y);
		}
	}
    
	x = _half + 20;
	
    {
    	MakePrimitive mp(GL_TRIANGLE_FAN);
		glColor4f (0.8f, 0.8f, 0.8f, 0.6f);
		glVertex2i (_half + 5, y);
		glColor4f (0, 0, 0, 0);
		for (i = 0; i <= 360; i += 36) {
			pos.x = sinf ((float)(i % 360) * DEGREES_TO_RADIANS) * radius;
			pos.y = cosf ((float)(i % 360) * DEGREES_TO_RADIANS) * radius;
			glVertex2i (x + (int)pos.x, _half + (int)pos.y);
		}
	}
    
	x = _half - 6;
	drawrect_simple (x - 3, y - 2, x + 2, y + 2, GLrgba (1.0f));
	x = _half + 6;
	drawrect_simple (x - 2, y - 2, x + 3, y + 2, GLrgba (1.0f));
}

/*-----------------------------------------------------------------------------
 Here is where ALL of the procedural textures are created.  It's filled with obscure logic, magic numbers, and messy code. Part of this is because 
 there is a lot of "art" being done here, and lots of numbers that could be endlessly tweaked.  Also because I'm lazy.
 -----------------------------------------------------------------------------*/

static void makeLattice(GLint size)
{
    pwLineWidth (2.0f);
    glColor3f (0,0,0);
    {	MakePrimitive mp(GL_LINES);
        glVertex2i (0, 0);  glVertex2i(size, size);	//diagonal
        glVertex2i (0, 0);  glVertex2i(0    , size);	//vertical
        glVertex2i (0, 0);  glVertex2i(size, 0    );	//vertical
    }
    
    MakePrimitive mp(GL_LINE_STRIP);
    glVertex2i(0, 0);
    for (int i = 0; i < size; i += 9)
        glVertex2i((i % 2) ? 0 : i, i);

    for (int i = 0; i < size; i += 9)
        glVertex2i(i, (i % 2) ? 0 : i);
}

static void makeSoftCircle(GLint halfSize)
{
	//Make a simple circle of light, bright in the center and fading out
    pwEnable (GL_BLEND);
    pwBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    float radius = float(halfSize) - 3;

    MakePrimitive mp(GL_TRIANGLE_FAN);
    glColor4f (1, 1, 1, 1);
    glVertex2i (halfSize, halfSize);
    glColor4f (0, 0, 0, 0);
    for (int i = 0; i <= 360; i++) {
        GLvector2 pos;
        pos.x = sinf ((float)i * DEGREES_TO_RADIANS) * radius;
        pos.y = cosf ((float)i * DEGREES_TO_RADIANS) * radius;
        glVertex2i (halfSize + (int)pos.x, halfSize + (int)pos.y);
    }
}

static void makeLight(GLint halfSize)
{
    pwEnable (GL_BLEND);
    pwBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    for (int j = 0; j < 2; j++) {
        MakePrimitive mp(GL_TRIANGLE_FAN);
        glColor4f (1.0f, 1.0f, 1.0f, 1.0f);
        glVertex2i (halfSize, halfSize);
        float radius = j ? 8 : (float(halfSize) / 2);
        glColor4f (1, 1, 1, 0);
        
        for (int i = 0; i <= 360; i++) {
            GLvector2 pos;
            pos.x = sinf (float(i) * DEGREES_TO_RADIANS) * radius;
            pos.y = cosf (float(i) * DEGREES_TO_RADIANS) * radius;
            glVertex2i (halfSize + int(pos.x), halfSize + int(pos.y));
        }
    }
}


//static void makeLogos(GLuint textureId, GLint size)
//{
//    pwDepthMask(GL_FALSE);
//    pwDisable(GL_BLEND);
//    int name_num = RandomInt(NAME_COUNT), prefix_num = RandomInt(PREFIX_COUNT), suffix_num = RandomInt(SUFFIX_COUNT);
//    glColor3f (1,1,1);
//    for (int i = 0; i < size; i += LOGO_PIXELS) {
//        GLint x = 2, y = size - i - LOGO_PIXELS / 4, numFonts = RenderGetNumFonts();
//            //randomly use a prefix OR suffix, but not both.  Too verbose.
//        if (COIN_FLIP())
//            RenderPrintIntoTexture(textureId, x, y, size, size,
//                                   RandomInt(numFonts),
//                                   [NSColor colorWithDeviceWhite:1.0f alpha:1.0f],
//                                   "%s%s", prefix[prefix_num], name[name_num]);
//        else
//            RenderPrintIntoTexture(textureId, x, y, size, size,
//                                   RandomInt(numFonts),
//                                   [NSColor colorWithDeviceWhite:1.0f alpha:1.0f],
//                                   "%s%s", name[name_num]    , suffix[suffix_num]);
//        name_num   = (name_num   + 1) % NAME_COUNT  ;
//        prefix_num = (prefix_num + 1) % PREFIX_COUNT;
//        suffix_num = (suffix_num + 1) % SUFFIX_COUNT;
//    }
//}

static void makeTrim(GLint size)
{
    int y = 0, margin = std::max(TRIM_PIXELS / 4, 1);
    for (int x = 0; x < size; x += TRIM_PIXELS)
        drawrect_simple(x + margin, y + margin    , x + TRIM_PIXELS - margin, y + TRIM_PIXELS - margin, GLrgba (1.0f), GLrgba (0.5f));
    y += TRIM_PIXELS;
    for (int x = 0; x < size; x += TRIM_PIXELS * 2)
        drawrect_simple(x + margin, y + margin    , x + TRIM_PIXELS - margin, y + TRIM_PIXELS - margin, GLrgba (1.0f), GLrgba (0.5f));
    y += TRIM_PIXELS;
    for (int x = 0; x < size; x += TRIM_PIXELS * 3)
        drawrect_simple(x + margin, y + margin    , x + TRIM_PIXELS - margin, y + TRIM_PIXELS - margin, GLrgba (1.0f), GLrgba (0.5f));
    y += TRIM_PIXELS;
    for (int x = 0; x < size; x += TRIM_PIXELS)
        drawrect_simple(x + margin, y + margin * 2, x + TRIM_PIXELS - margin, y + TRIM_PIXELS - margin, GLrgba (1.0f), GLrgba (0.5f));
}


void CTexture::Rebuild ()
{
	glReportError("CTexture::Rebuild BEGIN");
	
	unsigned long start = GetTickCount ();
	// Since we make textures by drawing into the viewport, we can't make them bigger than the current view.
	_size = _desired_size;
	int max_size = RenderMaxTextureSize ();
	while (_size > max_size)
		_size /= 2;
	pwBindTexture(GL_TEXTURE_2D, _glid);
    
	//Set up the texture
	pwTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, _size, _size, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	pwTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	pwTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	if (_clamp) {
		pwTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		pwTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}
    
	//Set up our viewport so that drawing into our texture will be as easy as possible.
    //We make the viewport and projection simply match the given texture size. 
	pwViewport(0, 0, _size , _size);
	pwMatrixMode (GL_PROJECTION);
	pwLoadIdentity ();
	glOrtho (0, _size, _size, 0, 0.1f, 2048);
    
	pwMatrixMode (GL_MODELVIEW);
    {
        PWMatrixStacker pushMatrix;
        pwLoadIdentity();
        
        pwDisable (GL_CULL_FACE);
        pwDisable (GL_FOG);
        pwBindTexture(GL_TEXTURE_2D, 0);
        pwTranslatef(0, 0, -10.0f);
        pwClearColor (0, 0, 0, _masked ? 0.0f : 1.0f);
        pwClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        pwPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        switch (_texType) {
            case TEXTURE_LATTICE    : makeLattice(_size)     ; break;
            case TEXTURE_SOFT_CIRCLE: makeSoftCircle(_half)  ; break;
            case TEXTURE_LIGHT      : makeLight(_half)       ; break;
            case TEXTURE_HEADLIGHT  : DrawHeadlight ()       ; break;
//            case TEXTURE_LOGOS      : makeLogos(_glid, _size); break;
            case TEXTURE_TRIM       : makeTrim(_size)        ; break;
            case TEXTURE_SKY        : DrawSky ()             ; break;
            default                 : DrawWindows()          ; break; //building textures
        }
    }
    
	//Now blit the finished image into our texture  
    bool use_framebuffer = true;
	if (use_framebuffer) {
		pwBindTexture(GL_TEXTURE_2D, _glid);
		pwCopyTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, _size, _size, 0);
	}
	if (_mipmap) {
		vector<unsigned char> bits(_size * _size * 4);
		pwGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, &bits[0]);
		pwuBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, _size, _size, GL_RGBA, GL_UNSIGNED_BYTE, &bits[0]);
		pwTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
		pwTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	} 
	else
		pwTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	_ready = true;
	unsigned long lapsed = GetTickCount() - start;
	build_time += lapsed;
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

unsigned TextureId (TextureType texType)
{
	for (CTexture* t = head; t; t = t->_next)
		if (t->_texType == texType)
			return t->_glid;
	return 0;
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

unsigned TextureRandomBuilding (unsigned long index)
{
	index = labs(index) % BUILDING_COUNT;
	return TextureId((TextureType)(TEXTURE_BUILDING1 + index));
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

void TextureReset (void)
{	
	textures_done = false;
	build_time = 0;
	for (CTexture* t = head; t; t = t->_next)
		t->Clear ();
//	memset(prefix_used, 0, sizeof(prefix_used));
//	memset(name_used  , 0, sizeof(name_used  ));
//	memset(suffix_used, 0, sizeof(suffix_used));	
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

bool TextureReady()
{	
	return textures_done;	
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

void TextureUpdate(bool showFlat, bool showBloom)
{
	glReportError("TextureUpdate:Beginning.");
	
	if (textures_done) {
		if (! showBloom)
			return;
		
		for(CTexture *t = head; t; t = t->_next) {
			if(t->_texType == TEXTURE_BLOOM) {
				do_bloom(t, showFlat);
				return;
			}
		}
	}

	for (CTexture* t = head; t; t = t->_next) {
		if(! t->_ready) {
			t->Rebuild();
			glReportError("TextureUpdate:After CTexture::Rebuild()");
			return;
		}
	}

	textures_done = true;
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

void TextureTerm (void)
{
	while (head) {
		CTexture* t = head->_next;
		free (head);
		head = t;
	}	
}

/*-----------------------------------------------------------------------------
 
 -----------------------------------------------------------------------------*/

void TextureInit (void)
{	
	new CTexture (TEXTURE_SKY,          512,  true,  false, false);
	new CTexture (TEXTURE_LATTICE,      128,  true,  true,  true);
	new CTexture (TEXTURE_LIGHT,        128,  false, false, true);
	new CTexture (TEXTURE_SOFT_CIRCLE,  128,  false, false, true);
	new CTexture (TEXTURE_HEADLIGHT,    128,  false, false, true);
	new CTexture (TEXTURE_TRIM,  TRIM_RESOLUTION,  true, false, false);
	new CTexture (TEXTURE_LOGOS, LOGO_RESOLUTION,  true, false, true);
	for (int i = TEXTURE_BUILDING1; i <= TEXTURE_BUILDING9; i++)
		new CTexture (TextureType(i), 512, true, false, false);
	new CTexture (TEXTURE_BLOOM,  512,  true, false, false);
}
