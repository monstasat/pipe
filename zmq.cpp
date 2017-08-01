#include <zmq.hpp>
#include <string>
#include <iostream>
#include <unistd.h>
#include <sys/poll.h>

int main(int argc, char** argv) {

    zmq::context_t context(1);
    zmq::socket_t socket(context,ZMQ_REQ);
    zmq::socket_t subscriber(context,ZMQ_SUB);

    std::cout << "Connecting to QoE backend..." << std::endl;

    socket.connect("ipc:///tmp/ats_qoe_in");
    subscriber.connect("ipc:///tmp/ats_qoe_out");
    const char* filter = "";
    subscriber.setsockopt(ZMQ_SUBSCRIBE,filter,strlen(filter));

    while (true) {
        zmq::pollitem_t items [] = {
            { subscriber, 0, ZMQ_POLLIN, 0},
            { 0, 0, ZMQ_POLLIN, 0}
        };
        int ret = zmq::poll(&items[0],2,-1);

        if (!ret) continue;

        if (items[0].revents & ZMQ_POLLIN) {
            zmq::message_t m;
            subscriber.recv(&m);
            std::string rep((char*)m.data(),m.size());
            std::cout << "\nReceived message from QoE publisher: " << rep << std::endl;
        }
        if (items[1].revents & ZMQ_POLLIN) {
            char resp [1024];
            ssize_t size = read(0, resp, 1023);
            zmq::message_t request(resp, size);
            std::string req((char*)request.data(), request.size());
            std::cout << "Sending request to QoE backend: " << req << std::endl;
            socket.send(request);

            zmq::message_t reply;
            socket.recv(&reply);
            std::string rep((char*)reply.data(), reply.size());
            std::cout << "\nReceived reply from QoE backend: " << rep << std::endl;
        }

        usleep(100);
    }

    return 0;
}
