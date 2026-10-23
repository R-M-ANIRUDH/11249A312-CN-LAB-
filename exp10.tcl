# Create a simulator object
set ns [new Simulator]

# Define different colors for traffic flows in NAM
$ns color 1 Blue
$ns color 2 Red

# Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

# Define the 'finish' procedure
proc finish {} { 
    global ns nf
    $ns flush-trace 
    close $nf
    exec nam out.nam & 
    exit 0
}

# Create four nodes
set n0 [$ns node] 
set n1 [$ns node] 
set n2 [$ns node] 
set n3 [$ns node]

# Create duplex links between the nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

# Set the queue limit for the bottleneck link
$ns queue-limit $n2 $n3 10

# Set node orientations for NAM layout
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

# Monitor the queue for NAM visualization
$ns duplex-link-op $n2 $n3 queuePos 0.5 

# Setup TCP Connection (n0 to n3)
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

# Setup FTP Application over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

# Setup UDP Connection (n1 to n3)
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp 
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 2

# Setup CBR Application over UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

# Schedule events for the simulation
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"
$ns at 5.0 "finish"

# Print CBR configuration details to the terminal
puts "CBR packet size = [$cbr set packet_size_]" 
puts "CBR interval = [$cbr set interval_]"

# Run the simulation
$ns run

