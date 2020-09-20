#include <algorithm>
#include <cmath>
#include <iostream>
#include <random>
#include <vector>

#include "neural_net.h"

using namespace std;

int main() {
    NeuralNet N({4, 1});

    vector<vector<double>> inputs;
    vector<vector<double>> targets;

    default_random_engine generator(time(0));
    normal_distribution<double> distribution(1, 1);

    for (size_t i = 0; i < 1000; ++i) {
        inputs.push_back({0, 0, 0, 0});
        targets.push_back({0});

        for (size_t k = 0; k < 4; ++k) {
            inputs[i][k] = distribution(generator);
        }

        targets[i][0] = (inputs[i][0] > 1) ? 1 : 0;
    }

    cout << "Start" << endl;

    for (size_t epoch = 0; epoch < 10000; ++epoch) {
        double sum = 0;
        size_t validationLen = 0;

        for (size_t i = 0; i < 1000; ++i) {
            N.ForwardPass(inputs[i]);

            vector<double> output = N.GetOutput();

            if (rand() % 100 < 50) {
                N.BackPropagation(output, targets[i]);
            } else {
                if ((output[0] > 0.5 && targets[i][0] < 0.5) || (output[0] < 0.5 && targets[i][0] > 0.5)) {
                    sum += 1;
                }
                validationLen++;
            }
        }

        if (epoch % 50 == 0) {
            cout << "Epoch " << epoch << ": " << sum / validationLen << endl;
            N.DumpWeights();
        }
    }

    return 0;
}
