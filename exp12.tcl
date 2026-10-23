# Create a simulator object
set ns [new Simulator]

# Define colors for different traffic flows in NAM
$ns color 1 Red
$ns color 2 Green

# Open the Trace and NAM files
set nr [open thro.tr w]
$ns trace-all $nr
set nf [open thro.nam w]
$ns namtrace-all $nf

# Define the finish procedure
proc finish { } {
    global ns nr nf
    $ns flush-trace
    close $nf
    close $nr
    exec nam thro.nam &
    exit 0
}

# Create 12 network nodes dynamically using a loop
for {set i 0} {$i < 12} {incr i 1} {
    set n($i) [$ns node]
}

# Establish physical links between nodes 0 to 8 sequentially
for {set i 0} {$i < 8} {incr i} {
    $ns duplex-link $n($i) $n([expr $i+1]) 1Mb 10ms DropTail
}

# Create additional cross-connecting topology links
$ns duplex-link $n(0) $n(8) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(10) 1Mb 10ms DropTail
$ns duplex-link $n(0) $n(9) 1Mb 10ms DropTail
$ns duplex-link $n(9) $n(11) 1Mb 10ms DropTail
$ns duplex-link $n(10) $n(11) 1Mb 10ms DropTail
$ns duplex-link $n(11) $n(5) 1Mb 10ms DropTail

# Configure Distance Vector (DV) Routing Protocol
$ns rtproto DV

# --- Traffic Flow 1: Node 0 to Node 5 (Red) ---
set udp0 [new Agent/UDP]
$udp0 set fid_ 1
$ns attach-agent $n(0) $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$ns attach-agent $n(5) $null0
$ns connect $udp0 $null0

# --- Traffic Flow 2: Node 1 to Node 5 (Green) ---
set udp1 [new Agent/UDP]
$udp1 set fid_ 2
$ns attach-agent $n(1) $udp1

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

set null1 [new Agent/Null]
$ns attach-agent $n(5) $null1
$ns connect $udp1 $null1

# --- Dynamic Network Topology Changes (Link Failures & Recoveries) ---
$ns rtmodel-at 10.0 down $n(11) $n(5)
$ns rtmodel-at 15.0 down $n(7) $n(6)
$ns rtmodel-at 20.0 up   $n(7) $n(6)
$ns rtmodel-at 30.0 up   $n(11) $n(5)

# --- Event Scheduling Timeline ---
$ns at 1.0 "$cbr0 start"
$ns at 2.0 "$cbr1 start"
$ns at 45.0 "finish"

# Start the simulation engine
$ns run

