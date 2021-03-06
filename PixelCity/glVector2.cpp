/*-----------------------------------------------------------------------------

  Vector2.cpp

  2006 Shamus Young
  Modified 2013 by Patrick A Wallace. If you find any bugs, assume they are mine.
  Released under the GNU GPL v3. See file COPYING for details.

-------------------------------------------------------------------------------

  Functions for dealing with 2d (usually texture mapping) values.

-----------------------------------------------------------------------------*/

#import "Model.h"

/*-----------------------------------------------------------------------------
                           
-----------------------------------------------------------------------------*/

GLvector2 glVectorNormalize (const GLvector2 &v)
{
  float length = v.Length();
  return (length < 0.000001f) ? v : v * (1.0f / length);
}

/*-----------------------------------------------------------------------------
                           
-----------------------------------------------------------------------------*/

float GLvector2::Length() const
{
    return (float)sqrt (x * x + y * y);
}

void GLvector2::glTexCoord2() const
{
    pwTexCoord2f(x, y);
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

GLvector2 glVectorSinCos(float a)
{
    a *= DEGREES_TO_RADIANS;
    return GLvector2(sinf (a), cosf (a));
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/

GLvector2 glVector(float x, float y)
{
  return GLvector2(x,y);
}


/*-----------------------------------------------------------------------------
                           
-----------------------------------------------------------------------------*/

GLvector2 glVectorInterpolate (GLvector2 v1, GLvector2 v2, float scalar)
{
  return GLvector2( MathInterpolate (v1.x, v2.x, scalar),
                    MathInterpolate (v1.y, v2.y, scalar) );
}  


/*-----------------------------------------------------------------------------
                      
-----------------------------------------------------------------------------*/

GLvector2::GLvector2()
:x(0.0f), y(0.0f)
{
}

std::ostream &GLvector2::operator<<(std::ostream &os) const
{
    return os << "[GLVECTOR2 X=" << x << ", Y=" << y << "]";
}

GLvector2 GLvector2::operator+ (const GLvector2& c) const
{
  return glVector (x + c.x, y + c.y);
}

GLvector2 GLvector2::operator+ (const float& c) const
{
  return glVector (x + c, y + c);
}

GLvector2 GLvector2::operator- (const GLvector2& c) const
{
  return glVector (x - c.x, y - c.y);
}

GLvector2 GLvector2::operator- (const float& c) const
{
  return glVector (x - c, y - c);
}

GLvector2 GLvector2::operator* (const GLvector2& c) const
{
  return glVector (x * c.x, y * c.y);
}

GLvector2 GLvector2::operator* (const float& c) const
{
  return glVector (x * c, y * c);
}

GLvector2 GLvector2::operator/ (const GLvector2& c) const
{
  return glVector (x / c.x, y / c.y);
}

GLvector2 GLvector2::operator/ (const float& c) const
{
  return glVector (x / c, y / c);
}

bool GLvector2::operator== (const GLvector2& c) const
{
  return (x == c.x && y == c.y);
}


