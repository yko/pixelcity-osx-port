// 2009 Shamus Young
// Modified 2013 by Patrick A Wallace. If you find any bugs, assume they are mine.
// Released under the GNU GPL v3. See file COPYING for details.

#import <vector>
#import "glVertex.h"

    // Terminator for list of ints in cube/fan/qs constructors.
static const int LIST_TERM = -1;

struct cube
{
    cube() {}
        // Constructor takes a list of index values and pushes them on to index_list.
        // End the list with LIST_TERM
        // Example cube c(1, 2, 3, 5, 8, LIST_TERM);
    cube(int first, ...);
    std::vector<GLulong> index_list;   // probably always .size() == 10...
    std::ostream &operator<<(std::ostream &os) const;
};
inline std::ostream &operator<<(std::ostream &os, const cube &c) { return c.operator<<(os); }

struct quad_strip
{
    quad_strip() {}
        // Constructor takes a list of index values and pushes them on to index_list.
        // End the list with LIST_TERM
        // Example quad_strip s(1, 2, 3, 5, 8, LIST_TERM);
    quad_strip(int first, ...);
    std::vector<GLulong> index_list;
    std::ostream &operator<<(std::ostream &os) const;
};
inline std::ostream &operator<<(std::ostream &os, const quad_strip &s) { return s.operator<<(os); }

struct fan
{
    fan() {}
        // Constructor takes a list of index values and pushes them on to index_list.
        // End the list with LIST_TERM
        // Example fan f(1, 2, 3, 5, 8, LIST_TERM);
    fan(int first, ...);
    std::vector<GLulong> index_list;
    std::ostream &operator<<(std::ostream &os) const;
};
inline std::ostream &operator<<(std::ostream &os, const fan &f) { return f.operator<<(os); }

@interface Mesh : NSObject
{
    unsigned                _list;
    size_t                  _polycount;
    std::vector<GLvertex>   _vertex;
    std::vector<cube>       _cube;
    std::vector<quad_strip> _quad_strip;
    std::vector<fan>        _fan;
    bool                    _compiled;
}

@property (nonatomic, readonly) size_t vertexCount, polyCount;
-(id)init;
-(void) addVertex:(const GLvertex&) v;
-(void) addCube:(const cube&) c;
-(void) addQuadStrip:(const quad_strip&) qs;
-(void) addFan:(const fan&) f;
-(void) Render;
-(void) Compile;

@end


