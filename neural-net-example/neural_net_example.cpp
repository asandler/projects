#include <algorithm>
#include <cmath>
#include <ctime>
#include <iostream>
#include <random>
#include <vector>

#include "neural_net.h"

using namespace std;

vector<double> targetFn(const vector<double>& inputs) {
    return {inputs[0] * 2 + inputs[1]};
}

vector<double> targetFn2(const vector<double>& inputs) {
    if ((inputs[0] < inputs[1]) && (-inputs[0] < inputs[1])) {
        return {1, 0, 0};
    } else if (inputs[0] > 0) {
        return {0, 1, 0};
    } else {
        return {0, 0, 1};
    }
}

vector<double> targetFn3(const vector<double>& inputs) {
    if (inputs[0] < inputs[1]) {
        return {1, 0};
    } else {
        return {0, 1};
    }
}

double sqr(double x) {
    return x * x;
}

size_t argmax(const vector<double>& a) {
    if (a.empty()) {
        throw runtime_error("argmax: empty input");
    }

    size_t result = 0;
    double curMax = a[0];

    for (size_t i = 1; i < a.size(); ++i) {
        if (a[i] > curMax) {
            curMax = a[i];
            result = i;
        }
    }

    return result;
}

double sqrDistance(const vector<double>& a, const vector<double>& b) {
    if (a.size() != b.size()) {
        throw runtime_error("Vector distance: a.size() != b.size()");
    }

    double result = 0;

    for (size_t i = 0; i < a.size(); ++i) {
        result += sqr(a[i] - b[i]);
    }

    return result;
}

int main() {
    NeuralNet N({
        {2, ACTIVATION_SIGMA},
        {4, ACTIVATION_SIGMA},
        {4, ACTIVATION_SIGMA},
        {3, ACTIVATION_SOFTMAX},
    }, /* learningRate = */ 0.1);

    vector<vector<double>> inputs;
    vector<vector<double>> targets;

    default_random_engine generator(static_cast<unsigned>(time(nullptr)));
    normal_distribution<double> distribution(0, 1);
    bernoulli_distribution trainSample(0.5);

    for (size_t i = 0; i < 1000; ++i) {
        inputs.push_back({0, 0});

        for (size_t k = 0; k < 2; ++k) {
            inputs[i][k] = distribution(generator);
        }

        targets.push_back(targetFn2(inputs[i]));
    }

    cout << "Start" << endl;

    vector<double> w1;

    for (size_t epoch = 0; epoch < 10000; ++epoch) {
        double errSquaredSum = 0;
        size_t validationLen = 0;
        size_t errCount = 0;

        for (size_t i = 0; i < 1000; ++i) {
            vector<double> output = N.ForwardPass(inputs[i]);

            if (trainSample(generator)) {
                N.BackPropagation(output, targets[i]);
            } else {
                if (argmax(output) != argmax(targets[i])) {
                    errCount++;
                }
                errSquaredSum += sqrDistance(output, targets[i]);
                validationLen++;
            }
        }

        double mse = errSquaredSum / validationLen;
        double errRatio = (double) errCount / validationLen;

        if (errRatio < 1e-5) {
            N.DumpWeights();
            return 0;
        }

        if (epoch % 50 == 0) {
            cout << "Epoch " << epoch << ", MSE = " << mse << ", errRatio = " << errRatio << endl;
        }
    }

    return 0;
}
