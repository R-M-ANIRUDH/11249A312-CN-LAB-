# Create a simulator object
set ns [new Simulator]

# Enable Distance Vector (DV) routing protocol
$ns rtproto DV

# Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf 

# Open the standard text trace file
set nt [open trace.tr w]
$ns trace-all $nt 

# Define the 'finish' procedure
proc finish {} { 
    global ns nf
    $ns flush-trace 
    close $nf
    exec nam -a out.nam & 
    exit 0
}

# Create eight nodes in a ring topology
set n1 [$ns node] 
set n2 [$ns node] 
set n3 [$ns node] 
set n4 [$ns node] 
set n5 [$ns node] 
set n6 [$ns node] 
set n7 [$ns node] 
set n8 [$ns node]

# Create duplex links to connect the nodes in a ring
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n4 $n5 1Mb 10ms DropTail
$ns duplex-link $n5 $n6 1Mb 10ms DropTail
$ns duplex-link $n6 $n7 1Mb 10ms DropTail
$ns duplex-link $n7 $n8 1Mb 10ms DropTail
$ns duplex-link $n8 $n1 1Mb 10ms DropTail

# Set node orientations for NAM layout (creates a circular shape)
$ns duplex-link-op $n1 $n2 orient left-up
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n4 $n5 orient right
$ns duplex-link-op $n5 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient down
$ns duplex-link-op $n7 $n8 orient left-down
$ns duplex-link-op $n8 $n1 orient left 

# Setup UDP Connection (n1 to n4)
set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0

# Setup CBR Application over UDP
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0 

# Setup Null Agent (the traffic sink at n4)
set null0 [new Agent/Null]
$ns attach-agent $n4 $null0
$ns connect $udp0 $null0

# Add visual text labels to the nodes in NAM
$ns at 0.0 "$n1 label Source"
$ns at 0.0 "$n4 label Destination"

# Schedule the simulation events
$ns at 0.5 "$cbr0 start"

# Dynamically break the link between n3 and n4 at 1.0 second
$ns rtmodel-at 1.0 down $n3 $n4

# Dynamically bring the link back up at 2.0 seconds
$ns rtmodel-at 2.0 up $n3 $n4

# End traffic generation and stop simulation
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"

# Run the simulation
$ns run

