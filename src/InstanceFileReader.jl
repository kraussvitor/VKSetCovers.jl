"""
Create an object of type graphs.Graph given the number of vertices and the list of edges.

# Parameters

    - num_verts::Int32 - number of vertices in the graph.
    - edges::Vector{Tuple{Int32, Int32}} - edges of the graph.

# Returns

    - ::Graphs.Graph - a Graphs.Graph object representing the graph.    
"""
function create_graph(
    num_verts::Int32,
    edges::Vector{Tuple{Int32, Int32}}
)::Graphs.Graph
    g = Graphs.Graph(num_verts)
    for (u, v) in edges
        Graphs.add_edge!(g, u, v)
    end
    return g
end

"""
Reads a set covering problem data from the given file.

# Parameters

    - input_file::String - string with the file path.

# Returns
    
    - num_ineqs::Int32 - number of inequalities in SCP instance.
    - num_vars::Int32 - number of variables in SCP instance.
    - var_spanned_ineqs::Vector{Vector{Int32}} - the set of inequalities covered by each variable.
    - var_costs::Vector{Int32} - the objective value cost of each variable.
"""
function read_set_cover_instance_from_file(
    input_file::String
)::NamedTuple{
    num_ineqs::Int32, 
    num_vars::Int32, 
    var_spanned_ineqs::Vector{Vector{Int32}}, 
    var_costs::Vector{Vector{Int32}}
}
    file = open(input_file, read=true)
    lines = readlines(file)
    sl = split(strip(lines[1]), " ")
    num_ineqs = parse(Int32, sl[1])
    num_vars = parse(Int32, sl[2])
    var_costs = zeros(Int32, num_vars)
    i = 2
    curr_var = 1
    # reading the costs
    while curr_var <= num_vars
        sl = split(strip(lines[i]), " ")
        for c in sl
            var_costs[curr_var] = parse(Int32, c)
            curr_var += 1
        end
        i += 1
    end
    # reading the var_spanned_ineqs
    var_spanned_ineqs = [zeros(Int32, 0) for j in 1:num_vars]
    curr_row = 1
    while curr_row <= num_ineqs
        sl = split(strip(lines[i]), " ")
        n = parse(Int32, sl[1])
        j = 0
        while j < n
            i += 1
            sl = split(strip(lines[i]), " ")
            for s in sl
                push!(var_spanned_ineqs[parse(Int32, s)], curr_row)
                j += 1
            end
        end
        curr_row += 1
        i += 1
    end
    return (
        num_ineqs,
        num_vars,
        var_spanned_ineqs,
        var_costs
    )
end

"""
Returns an object of type SetCoverInstance containing the data of the given set cover instance.

# Parameters

    - input_file::String - string with the file path.

# Returns

    - ::SetCoverInstance - object with SCP instance data.
"""
function get_set_cover_instance_from_file(
    input_file::String
)::SetCoverInstance
    num_ineqs, num_vars, var_spanned_ineqs, var_costs = read_set_cover_instance_from_file(input_file)
    return init_set_cover_instance(
        num_ineqs,
        num_vars,
        var_spanned_ineqs,
        var_costs
    )
end

"""
Reads a graph stored in .mxt format in the given file.

# Parameters

    - input_file::String - string with the file path.

# Returns

    - num_verts::Int32 - number of vertices in the graph.
    - num_edges::Int32 - number of edges in the graph.
    - edges::Vector{Tuple{Int32, Int32}} - edges of the graph.
"""
function read_graph_from_mtx_file(
    input_file::String
)::NamedTuple{
    num_verts::Int32,
    num_edges::Int32,
    edges::Vector{Tuple{Int32, Int32}}
}
    file = open(input_file, read=true)
    lines = readlines(file)
    curr_line = 2
    sl = split(strip(lines[curr_line]), " ")
    num_verts = parse(Int32, sl[2])
    num_edges = parse(Int32, sl[3])
    edges = Vector{Tuple{Int32, Int32}}(undef, num_edges)
    for i in 1:num_edges
        curr_line += 1
        sl = split(strip(lines[curr_line]), " ")
        u = parse(Int32, sl[1])
        v = parse(Int32, sl[2])
        edges[i] = (min(u,v), max(u,v))
    end
    return (
        num_verts = num_verts,
        num_edges = num_edges,
        edges = edges
    )
end

"""
Returns an object of type Graphs.Graph representing the graph stored in the given .mtx format file.

# Parameters

    - input_file::String - string with the file path.

# Returns
    
    - ::Graphs.Graph - a Graphs.Graph object representing the graph.
"""
function get_graph_from_mtx_file(
    input_file::String
)::Graphs.Graph
    num_verts, num_edges, edges = read_graph_from_mtx_file(input_file)
    return create_graph(
        num_verts,
        edges
    )
end

"""
Reads the data of the undirected Steiner tree problem instance in the given file.

The data corresponds to: graph vertices and edges, edge weights and terminal vertices.

# Parameters

    - input_file::String - string with the file path.

# Returns

    - num_verts::Int32 - number of vertices in the graph.
    - num_edges::Int32 - number of edges in the graph.
    - edges::Vector{Tuple{Int32, Int32}} - the edges of the graph.
    - edge_weights::Dict{Tuple{Int32, Int32}, Int32} - the weight for each edge.
    - terminal_verts::Vector{Int32} - the set of terminal vertices.
"""
function read_undirected_steiner_tree_instance_from_file(
    input_file::String
)::@NamedTuple{
    num_verts::Int32,
    num_edges::Int32, 
    edges::Vector{Tuple{Int32, Int32}}, 
    edge_weights::Dict{Tuple{Int32, Int32}, Int32},
    terminal_verts::Vector{Int32}
}
    file = open(input_file, read=true)
    lines = readlines(file)
    # searching for starting line of section graph
    curr_line = 1
    sl = strip(lines[curr_line])
    while lowercase(sl) != "section graph"
        curr_line += 1
        sl = strip(lines[curr_line])
    end
    # reading number of vertices
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    num_verts = parse(Int32, sl[2])
    # reading number of edges
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    num_edges = parse(Int32, sl[2])
    # reading edges
    edges = Vector{Tuple{Int32, Int32}}(undef, num_edges)
    edge_weights = Dict{Tuple{Int32, Int32}, Int32}()
    for i in 1:num_edges
        curr_line += 1
        sl = split(strip(lines[curr_line]), " ")
        u = parse(Int32, sl[2])
        v = parse(Int32, sl[3])
        w = parse(Int32, sl[4])
        e = get_sorted_tuple(u, v)
        edges[i] = e
        edge_weights[e] = w
    end
    # searching for starting line of section terminals
    curr_line = 1
    sl = strip(lines[curr_line])
    while lowercase(sl) != "section terminals"
        curr_line += 1
        sl = strip(lines[curr_line])
    end
    # reading number of terminals
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    num_terminals = parse(Int32, sl[2])
    terminal_verts = zeros(Int32, num_terminals)
    # reading terminal vertices
    for i in 1:num_terminals
        curr_line += 1
        sl = split(strip(lines[curr_line]), " ")
        u = parse(Int32, sl[2])
        terminal_verts[i] = u
    end
    return (
        num_verts = num_verts,
        num_edges = num_edges, 
        edges = edges, 
        edge_weights = edge_weights, 
        terminal_verts = terminal_verts
    )
end

"""
Reads the data of the directed Steiner tree problem instance in the given file.

The data corresponds to: graph vertices and arcs, arc weights and terminal vertices.

# Parameters

    - input_file::String - string with the file path.

# Returns

    - num_verts::Int32 - number of vertices in the digraph.
    - num_arcs::Int32 - number of arcs in the digraph.
    - edges::Vector{Tuple{Int32, Int32}} - the edges of the digraph.
    - edge_weights::Dict{Tuple{Int32, Int32}, Int32} - the weight for each arc.
    - terminal_verts::Vector{Int32} - the set of terminal vertices.
    - root::Int32 - the root vertex.
"""
function read_directed_steiner_tree_instance_from_file(
    input_file::String
)::@NamedTuple{
    num_verts::Int32,
    num_arcs::Int32, 
    arcs::Vector{Tuple{Int32, Int32}}, 
    arc_weights::Dict{Tuple{Int32, Int32}, Int32},
    terminal_verts::Vector{Int32},
    root::Int32
}
    file = open(input_file, read=true)
    lines = readlines(file)
    # searching for starting line of section graph
    curr_line = 1
    sl = strip(lines[curr_line])
    while lowercase(sl) != "section graph"
        curr_line += 1
        sl = strip(lines[curr_line])
    end
    # reading number of vertices
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    num_verts = parse(Int32, sl[2])
    # reading number of edges
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    num_arcs = parse(Int32, sl[2])
    # reading edges
    arcs = Vector{Tuple{Int32, Int32}}(undef, num_arcs)
    arc_weights = Dict{Tuple{Int32, Int32}, Int32}()
    for i in 1:num_arcs
        curr_line += 1
        sl = split(strip(lines[curr_line]), " ")
        filter!(
            s -> !isempty(s),
            sl
        )
        u = parse(Int32, sl[2])
        v = parse(Int32, sl[3])
        w = parse(Int32, sl[4])
        e = (u, v)
        arcs[i] = e
        arc_weights[e] = w
    end
    # searching for starting line of section terminals
    curr_line = 1
    sl = strip(lines[curr_line])
    while lowercase(sl) != "section terminals"
        curr_line += 1
        sl = strip(lines[curr_line])
    end
    # reading number of terminals
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    num_terminals = parse(Int32, sl[2])
    terminal_verts = zeros(Int32, num_terminals)
    # reading root
    curr_line += 1
    sl = split(strip(lines[curr_line]), " ")
    root_vertex = parse(Int32, sl[2])
    # reading terminal vertices
    for i in 1:num_terminals
        curr_line += 1
        sl = split(strip(lines[curr_line]), " ")
        filter!(
            s -> !isempty(s),
            sl
        )
        u = parse(Int32, sl[2])
        terminal_verts[i] = u
    end
    return (
        num_verts = num_verts,
        num_arcs = num_arcs, 
        arcs = arcs, 
        arc_weights = arc_weights, 
        terminal_verts = terminal_verts,
        root = root_vertex
    )
end