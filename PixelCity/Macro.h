// 2009 Shamus Young
// Modified 2013 by Patrick A Wallace. If you find any bugs, assume they are mine.
// Released under the GNU GPL v3. See file COPYING for details.

inline GLuint WRAP(GLuint x, GLuint y) { return GLuint(x) % y; }

template <class T> inline const T& CLAMP(const T& a, const T& b, const T& c) { return (a < b ? b : (a > c ? c : a)); }

// ABS is a macro in Objective-C
#if !defined(ABS)
template <class T> inline const T& ABS (const T& x) { return (((x) < 0 ? (-x) : (x))); }
#endif

template <class T> inline const T& SMALLEST(const T& x, const T& y) { return (ABS(x) < ABS(y)) ? 0 : x; }
template <class T> float POW(T& x, T& y) { return float(pow(x,y)); }

template <class T> inline int SIGN(const T& x)
{
    return (x > 0) ?  1
                   : (x < 0) ? -1
                             :  0;
}


inline GLubyte GetRValue(GLulong rgb) { return GLubyte(rgb); }
inline GLubyte GetGValue(GLulong rgb) { return GLubyte(GLushort(rgb) >> 8 ); }
inline GLubyte GetBValue(GLulong rgb) { return GLubyte(GLushort(rgb) >> 16); }

