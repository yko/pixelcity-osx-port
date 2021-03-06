/*-----------------------------------------------------------------------------

  glBbox.cpp

  2006 Shamus Young
  Modified 2013 by Patrick A Wallace. If you find any bugs, assume they are mine.
  Released under the GNU GPL v3. See file COPYING for details.

-------------------------------------------------------------------------------
  
  This module has a few functions useful for manipulating the bounding-box 
  structs.

-----------------------------------------------------------------------------*/

#import "Model.h"

static const float MAX_VALUE = 999999999999999.9f;

/*-----------------------------------------------------------------------------
Does the given point fall within the given Bbox?
-----------------------------------------------------------------------------*/

bool glBboxTestPoint (GLbbox box, GLvector point)
{

  if (point.x > box.max.x || point.x < box.min.x)
    return false;
  if (point.y > box.max.y || point.y < box.min.y)
    return false;
  if (point.z > box.max.z || point.z < box.min.z)
    return false;
  return true;

}

/*-----------------------------------------------------------------------------
Expand Bbox (if needed) to contain given point
-----------------------------------------------------------------------------*/

GLbbox glBboxContainPoint (GLbbox box, GLvector point)
{

  box.min.x = std::min(box.min.x, point.x);
  box.min.y = std::min(box.min.y, point.y);
  box.min.z = std::min(box.min.z, point.z);
  box.max.x = std::max(box.max.x, point.x);
  box.max.y = std::max(box.max.y, point.y);
  box.max.z = std::max(box.max.z, point.z);
  return box;
  
}

// Create a new Bbox big enough to contain these two corner points.
GLbbox bboxWithCorners(const GLvector &topLeftFront, const GLvector &bottomRightBack)
{
    return glBboxContainPoint(glBboxContainPoint(glBboxClear(), topLeftFront), bottomRightBack);
}

/*-----------------------------------------------------------------------------
This will invalidate the bbox. 
-----------------------------------------------------------------------------*/

GLbbox glBboxClear (void)
{

  GLbbox      result;

  result.max = glVector (-MAX_VALUE, -MAX_VALUE, -MAX_VALUE);
  result.min = glVector ( MAX_VALUE,  MAX_VALUE,  MAX_VALUE);
  return result;

}


