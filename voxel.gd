tool
extends MeshInstance

func _process(delta):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#front
	st.add_vertex(Vector3(-.5,.5,-.5))
	st.add_vertex(Vector3(-.5,-.5,-.5))
	st.add_vertex(Vector3(.5,-.5,-.5))
	st.add_vertex(Vector3(.5,-.5,-.5))
	st.add_vertex(Vector3(.5,.5,-.5))
	st.add_vertex(Vector3(-.5,.5,-.5))
	#back
	st.add_vertex(Vector3(-.5,.5,.5))
	st.add_vertex(Vector3(.5,.5,.5))
	st.add_vertex(Vector3(.5,-.5,.5))
	st.add_vertex(Vector3(.5,-.5,.5))
	st.add_vertex(Vector3(-.5,-.5,.5))
	st.add_vertex(Vector3(-.5,.5,.5))
	#top
	st.add_vertex(Vector3(-.5,.5,-.5))
	st.add_vertex(Vector3(.5,.5,-.5))
	st.add_vertex(Vector3(.5,.5,.5))
	st.add_vertex(Vector3(.5,.5,.5))
	st.add_vertex(Vector3(-.5,.5,.5))
	st.add_vertex(Vector3(-.5,.5,-.5))
	#bottom
	st.add_vertex(Vector3(-.5,-.5,-.5))
	st.add_vertex(Vector3(-.5,-.5,.5))
	st.add_vertex(Vector3(.5,-.5,.5))
	st.add_vertex(Vector3(.5,-.5,.5))
	mesh = st.commit()