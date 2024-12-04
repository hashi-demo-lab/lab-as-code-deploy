from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.security import Vault
from diagrams.generic.device import Mobile  # Using this to represent HSM since there's no specific HSM icon
from diagrams.generic.blank import Blank  # Placeholder for logical connections

# Custom Graphviz attributes
graph_attrs = {
    "fontsize": "20",
    "bgcolor": "white",
    "labelloc": "t",
    "labeljust": "c",
    "pad": "0.5",
}

node_attrs = {
    "fontsize": "14",
    "fontcolor": "black",
    "style": "filled,solid",
    "fillcolor": "#eaf6f6",  # Light teal for Vault nodes
    "pencolor": "#3a7c7c",  # Dark teal for node borders
    "penwidth": "1.5",
}

cluster_attrs = {
    "fontsize": "16",
    "fontcolor": "black",
    "style": "filled",
    "fillcolor": "#f7f7f7",  # Light gray for clusters
    "pencolor": "#a6a6a6",  # Subtle gray for cluster borders
    "penwidth": "2",
}

with Diagram(
    "Enhanced Vault Cluster with DR and HSM Connections",
    show=False,
    direction="TB",
    graph_attr=graph_attrs,
    node_attr=node_attrs,
    edge_attr={"fontsize": "12", "color": "#606060", "penwidth": "2"},
):
    # Define the HSMs on the right
    with Cluster("HSM HA Pair", graph_attr={"fillcolor": "#e7f0e7", "pencolor": "#9e9e9e", "penwidth": "2"}):  # Soft green
        hsm1 = Mobile("HSM 1")
        hsm2 = Mobile("HSM 2")
        # Connect HSMs to show HA relationship
        hsm1 - Edge(color="#cc0000", style="dashed", label="HA", fontsize="12") - hsm2

    # Define the Primary Cluster at the top
    with Cluster("Primary Cluster", graph_attr={"fillcolor": "#e8f1fa", "pencolor": "#4682b4"}):  # Light blue for primary cluster
        primary_placeholder = Blank("")  # Logical placeholder for the cluster
        with Cluster("Datacenter 1", graph_attr={"fillcolor": "#fff3e6", "pencolor": "#d6a57e"}):  # Light peach
            dc1_primary = [Vault("Vault Node 1"), Vault("Vault Node 2")]

        with Cluster("Datacenter 2", graph_attr={"fillcolor": "#f5e6f8", "pencolor": "#a678b0"}):  # Light lavender
            dc2_primary = [Vault("Vault Node 3"), Vault("Vault Node 4")]

        with Cluster("Datacenter 3", graph_attr={"fillcolor": "#e7f5e7", "pencolor": "#7ba77c"}):  # Light green
            dc3_primary = [Vault("Vault Node 5")]

        # Connect all Primary nodes
        dc1_primary[0] - dc1_primary[1] - dc2_primary[0] - dc2_primary[1] - dc3_primary[0]

    # Define the DR Cluster below the Primary Cluster
    with Cluster("DR Cluster", graph_attr={"fillcolor": "#fde6e6", "pencolor": "#c46363"}):  # Light coral for DR cluster
        dr_placeholder = Blank("")  # Logical placeholder for the cluster
        with Cluster("Datacenter 1", graph_attr={"fillcolor": "#fff3e6", "pencolor": "#d6a57e"}):  # Light peach
            dc1_dr = [Vault("Vault Node 1"), Vault("Vault Node 2")]

        with Cluster("Datacenter 2", graph_attr={"fillcolor": "#f5e6f8", "pencolor": "#a678b0"}):  # Light lavender
            dc2_dr = [Vault("Vault Node 3"), Vault("Vault Node 4")]

        with Cluster("Datacenter 3", graph_attr={"fillcolor": "#e7f5e7", "pencolor": "#7ba77c"}):  # Light green
            dc3_dr = [Vault("Vault Node 5")]

        # Connect all DR nodes
        dc1_dr[0] - dc1_dr[1] - dc2_dr[0] - dc2_dr[1] - dc3_dr[0]

    # Connect Primary Cluster to HSMs
    primary_placeholder - Edge(color="#4682b4", style="bold", label="Connected to HSM") - hsm1
    primary_placeholder - Edge(color="#4682b4", style="bold", label="Connected to HSM") - hsm2

    # Connect DR Cluster to HSMs
    dr_placeholder - Edge(color="#c46363", style="dashed", label="Connected to HSM") - hsm1
    dr_placeholder - Edge(color="#c46363", style="dashed", label="Connected to HSM") - hsm2
