#include <algorithm>
#include <cmath>
#include <iostream>
#include <random>
#include <vector>

#include "neural_net.h"

using namespace std;

double targetFn(const vector<double>& inputs) {
    return inputs[0] * 2 + inputs[1];
}

double targetFn2(const vector<double>& inputs) {
    if ((inputs[0] < inputs[1]) && (-inputs[0] < inputs[1])) {
        return 1.0 / 5;
    } else if (inputs[0] > 0) {
        return 2.0 / 5;
    } else {
        return 4.0 / 5;
    }
}

int main() {
    NeuralNet N({2, 4, 4, 1}, /* learningRate = */ 0.01, ACTIVATION_SIGMA);

    vector<vector<double>> inputs;
    vector<vector<double>> targets;

    default_random_engine generator(time(0));
    normal_distribution<double> distribution(0, 1);

    for (size_t i = 0; i < 1000; ++i) {
        inputs.push_back({0, 0});

        for (size_t k = 0; k < 2; ++k) {
            inputs[i][k] = distribution(generator);
        }

        targets.push_back({targetFn2(inputs[i])});
    }

    N.DumpWeights();
    cout << "Start" << endl;

    for (size_t epoch = 0; epoch < 10000; ++epoch) {
        double errSquaredSum = 0;
        size_t validationLen = 0;

        for (size_t i = 0; i < 1000; ++i) {
            vector<double> output = N.ForwardPass(inputs[i]);
            //vector<double> w1 = N.GetWeights();

            if (rand() % 100 < 50) {
                N.BackPropagation(output, targets[i]);
                //vector<double> w2 = N.GetWeights();
                //double diff = 0;
                //cout << "(";
                //for (size_t j = 0; j < w1.size(); ++j) {
                //    diff += (w1[j] - w2[j]) * (w1[j] - w2[j]);
                //    cout << w1[j] - w2[j] << ", ";
                //}
                //cout << ") - ";
                //cout << "Weight diff: " << sqrt(diff) << endl;
            } else {
                errSquaredSum += (targets[i][0] - output[0]) * (targets[i][0] - output[0]);
                validationLen++;
            }

            if (epoch % 50 == 0) {
                cerr << inputs[i][0] << " " << inputs[i][1] << " " << output[0] << " " << targets[i][0] << endl;
            }
        }

        double mse = errSquaredSum / validationLen;

        if (epoch % 50 == 0) {
            cout << "Epoch " << epoch << ", MSE = " << mse << endl;
        }
    }

    return 0;
}
