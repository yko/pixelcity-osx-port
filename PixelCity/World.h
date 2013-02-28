
@class Cars, Entities, Lights, Textures, Sky, Camera, VisibilityGrid, Renderer;

@interface World : NSObject
{
}
#pragma mark - Properties

@property (nonatomic, readonly) GLrgba  bloomColor;
@property (nonatomic, readonly) GLuint  logoIndex;
@property (nonatomic, readonly) GLbbox  hotZone;
@property (nonatomic, readonly) float   fadeCurrent;
@property (nonatomic, readonly) GLulong fadeStart;
@property (nonatomic, readonly) GLulong sceneBegin;
@property (nonatomic, readonly) GLulong sceneElapsed;

@property (nonatomic, readonly) Cars     *cars;
@property (nonatomic, readonly) Entities *entities;
@property (nonatomic, readonly) Lights   *lights;
@property (nonatomic, readonly) Textures *textures;
@property (nonatomic, readonly) Sky      *sky;
@property (nonatomic, readonly) Camera   *camera;
@property (nonatomic, readonly) Renderer *renderer;
@property (nonatomic, readonly) VisibilityGrid *visibilityGrid;

#pragma mark - Methods

-(id) initWithViewSize:(const CGSize &) viewSize;


    // Reset the contents of the world if necessary.
-(void) reset;

    // Start closing down the scene. Prevent any more drawing while we wait for the window to close.
-(void) term;

    // Update all the actors in the scene (move cars, change camera angle etc.)
-(void) update:(const CGSize &) viewSize;

    // Draw the scene to the OpenGL context.
-(void) draw;

    // Return the state of one of the cells on the grid.
-(char) cellAtRow:(int) row column:(int) column;

    // For debugging -draw a grid showing traffic lanes over the city.
-(void) renderDebugTrafficLanes;

@end

#pragma mark - Helper classes for display-list rendering & primitive creation. 

// Avoid stack overflows by using RAII.
//struct MakePrimitive
//{
//	static int nestCount;	// debug variable used to check we are not nesting.
//	MakePrimitive(GLenum type);
//	~MakePrimitive();
//};
//
//struct MakeDisplayList
//{
//	static int nestCount;	// debug variable used to check we are not nesting.
//	MakeDisplayList(GLint name, GLenum mode, const char *location);
//	~MakeDisplayList();
//};	

//
//struct PWMatrixStacker
//{
//    PWMatrixStacker();
//    ~PWMatrixStacker();
//};





