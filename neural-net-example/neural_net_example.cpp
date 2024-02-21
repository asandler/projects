#include <algorithm>
#include <cmath>
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
    double curMax = -1e9;

    for (size_t i = 0; i < a.size(); ++i) {
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

void printDbgInfo(
    const vector<double>& inputs,
    const vector<double>& output,
    const vector<double>& targets
) {
    cerr << "inputs: {";
    for (size_t i = 0; i < inputs.size(); ++i) {
        cerr << inputs[i] << ", ";
    }

    cerr << "}, output: {";
    for (size_t i = 0; i < output.size(); ++i) {
        cerr << output[i] << ", ";
    }

    cerr << "}, targets: {";
    for (size_t i = 0; i < targets.size(); ++i) {
        cerr << targets[i] << ", ";
    }

    cerr << "}" << endl;
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

    default_random_engine generator(time(0));
    normal_distribution<double> distribution(0, 1);

    for (size_t i = 0; i < 1000; ++i) {
        inputs.push_back({0, 0});

        for (size_t k = 0; k < 2; ++k) {
            inputs[i][k] = distribution(generator);
        }

        targets.push_back(targetFn2(inputs[i]));
    }

    N.DumpWeights();
    cout << "Start" << endl;

    vector<double> w1;
    vector<double> w2;

    for (size_t epoch = 0; epoch < 10000; ++epoch) {
        double errSquaredSum = 0;
        size_t validationLen = 0;
        size_t errCount = 0;
        bool printDbg = (epoch % 50 == 0);

        if (printDbg) {
            cerr << "Epoch " << epoch << endl;
        }

        for (size_t i = 0; i < 1000; ++i) {
            vector<double> output = N.ForwardPass(inputs[i]);

            if (printDbg) {
                printDbgInfo(inputs[i], output, targets[i]);
                w1 = N.GetWeights();
            }

            if (rand() % 100 < 50) {
                N.BackPropagation(output, targets[i]);

                if (printDbg) {
                    auto w2 = N.GetWeights();
                    auto output2 = N.ForwardPass(inputs[i]);

                    cerr << "Weight diff: " << sqrt(sqrDistance(w1, w2)) << endl;
                    cerr << "Output diff: " << sqrt(sqrDistance(output, output2)) << endl;

                    cerr << "after backprop" << endl;
                    printDbgInfo(inputs[i], output2, targets[i]);
                }
            } else {
                if (printDbg) {
                    cerr << "added error " << sqrDistance(output, targets[i]) << endl;
                }
                if (argmax(output) != argmax(targets[i])) {
                    errCount++;
                }
                errSquaredSum += sqrDistance(output, targets[i]);
                validationLen++;
            }
        }

        double mse = errSquaredSum / validationLen;
        double errRatio = (double) errCount / validationLen;

        if (epoch % 50 == 0) {
            cout << "Epoch " << epoch << ", MSE = " << mse << ", errRatio = " << errRatio << endl;
        }
    }

    return 0;
}
