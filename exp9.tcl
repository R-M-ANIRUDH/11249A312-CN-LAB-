# Create a simulator object
set ns [new Simulator]

# Open the trace file and NAM file
set tracefile [open congestion.tr w]
$ns trace-all $tracefile
set namfile [open congestion.nam w]
$ns namtrace-all $namfile

# Define different colors for traffic flows in NAM
$ns color 1 Blue
$ns color 2 Red

# Create six nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create duplex links between the nodes
$ns duplex-link $n0 $n2 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 20ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link $n3 $n5 10Mb 10ms DropTail

# Set the queue limit for the bottleneck link (n2 to n3)
$ns queue-limit $n2 $n3 20

# Monitor the queue for NAM visualization
$ns duplex-link-op $n2 $n3 queuePos 0.5

# Setup TCP Connection (n0 to n4)
set tcp [new Agent/TCP]
$tcp set fid_ 1; # Blue color for TCP
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

# Setup FTP Application over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Setup UDP Connection (n1 to n5)
set udp [new Agent/UDP]
$udp set fid_ 2; # Red color for UDP
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n5 $null
$ns connect $udp $null

# Setup CBR Application over UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 1000
$cbr set interval_ 0.005

# Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam congestion.nam &
    exit 0
}

# Schedule events for the simulation
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr start"
$ns at 8.5 "$ftp stop"
$ns at 9.0 "$cbr stop"
$ns at 10.0 "finish"

# Run the simulation
$ns run

