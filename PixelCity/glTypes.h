#ifndef glTYPES
#define glTYPES

#include <iostream>
#import <OpenGL/OpenGL.h>

#define GL_CLAMP_TO_EDGE 0x812F

#define OPERATORS(type)                 \
  type();                               \
  type    operator+  (const type& c);   \
  type    operator+  (const float& c);  \
  void    operator+= (const type& c);   \
  void    operator+= (const float& c);  \
  type    operator-  (const type& c);   \
  type    operator-  (const float& c);  \
  void    operator-= (const type& c);   \
  void    operator-= (const float& c);  \
  type    operator*  (const type& c);   \
  type    operator*  (const float& c);  \
  void    operator*= (const type& c);   \
  void    operator*= (const float& c);  \
  type    operator/  (const type& c);   \
  type    operator/  (const float& c);  \
  void    operator/= (const type& c);   \
  void    operator/= (const float& c);  \
  bool    operator== (const type& c);   \
  std::ostream &operator<<(std::ostream &os) const;

#define JOINT_MAX_CHILDREN  8

struct GLquat
{
  float       x;
  float       y;
  float       z;
  float       w;
};

struct GLvector
{
  float       x;
  float       y;
  float       z;
  OPERATORS(GLvector);
  GLvector(float xx, float yy, float zz) : x(xx), y(yy), z(zz) {}
};
inline std::ostream &operator<<(std::ostream &os, const GLvector &v) { return v.operator<<(os); }

typedef GLvector       GLvector3;

struct GLvector2
{
  float       x;
  float       y;
  OPERATORS(GLvector2);
};
inline std::ostream &operator<<(std::ostream &os, const GLvector2 &v) { return v.operator<<(os); }

struct GLmatrix
{
  float elements[4][4];
};

struct GLbbox
{
  GLvector3   min;
  GLvector3   max;
};

struct GLrect
{
  float       left;
  float       top;
  float       right;
  float       bottom;
};

struct GLtriangle
{
  int         v1;
  int         v2;
  int         v3;
  int         normal1;
  int         normal2;
  int         normal3;
};

/*
class GLmodel
{
public:
  unsigned    vertex_count;
  unsigned    triangle_count;
  unsigned    normal_count;
  GLvertex*   vertex;  
  GLvector*   normal;
  GLtriangle* triangle;

  void        TriangleRender (unsigned n);
  GLtriangle* TriangleAdd (unsigned v1, int unsigned, int unsigned);
  GLtriangle* TriangleAdd (GLtriangle c);
  void        NormalAdd (GLvector n);
  void        VertexAdd (GLvertex v);
              GLmodel ();
              ~GLmodel ();
  void        Render ();
  GLbbox      BBox ();
private:
  GLbbox      m_bbox;

};

struct GLkeyframe
{
  float     time;
  GLvector  offset;
  GLvector  rotation;
};

struct GLsegment
{
  int           index;
  GLvector      rotation;
  GLvector      offset;
  GLkeyframe    keyframes[255];
  int           frame_count;
};

class GLanimate
{
public:
                GLanimate ();
  void          KeyframeAdd (int joint, float time, GLquat q);
  void          TimeSet (float time);
  void          PositionSet (float pos);
  GLvector      Rotation (int);
  GLvector      Offset (int);

private:
  GLsegment*    m_segments;
  int           m_segment_count;
  float         m_length;
};
*/

GLbbox    glBboxClear (void);
GLbbox    glBboxContainPoint (GLbbox box, GLvector point);
bool      glBboxTestPoint (GLbbox box, GLvector point);


GLmatrix  glMatrixIdentity (void);
void      glMatrixElementsSet (GLmatrix* m, float* in);
GLmatrix  glMatrixMultiply (GLmatrix a, GLmatrix b);
GLvector  glMatrixTransformPoint (GLmatrix m, GLvector in);
GLmatrix  glMatrixTranslate (GLmatrix m, GLvector in);
GLmatrix  glMatrixRotate (GLmatrix m, float theta, float x, float y, float z);
GLvector  glMatrixToEuler (GLmatrix mat, int order);

GLquat    glQuat (float x, float y, float z, float w);
GLvector  glQuatToEuler (GLquat q, int order);

GLvector  glVector (float x, float y, float z);
GLvector  glVectorCrossProduct (GLvector v1, GLvector v2);
float     glVectorDotProduct (GLvector v1, GLvector v2);
void      glVectorGl (GLvector v);
GLvector  glVectorInterpolate (GLvector v1, GLvector v2, float scalar);
float     glVectorLength (GLvector v);
GLvector  glVectorNormalize (GLvector v);
GLvector  glVectorReflect (GLvector3 ray, GLvector3 normal);
inline GLvector glVector(int x, int y, int z) { return glVector(float(z), float(y), float(z)); }

GLvector2 glVector (float x, float y);
GLvector2 glVectorAdd (GLvector2 val1, GLvector2 val2);
GLvector2 glVectorSubtract (GLvector2 val1, GLvector2 val2);
GLvector2 glVectorNormalize (GLvector2 v);
GLvector2 glVectorInterpolate (GLvector2 v1, GLvector2 v2, float scalar);
GLvector2 glVectorSinCos (float angle);
float     glVectorLength (GLvector2 v);
inline GLvector2 glVector(int x, int y) { return glVector(float(x), float(y)); }

#endif

#ifndef NULL
#define NULL  0
#endif
