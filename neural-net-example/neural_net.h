#pragma once

#include <algorithm>
#include <cmath>
#include <iostream>
#include <random>
#include <vector>

using namespace std;

enum ActivationType {
    ACTIVATION_NONE,
    ACTIVATION_SIGMA,
    ACTIVATION_RELU,
    ACTIVATION_SOFTMAX,
};

class Neuron {
public:
    Neuron(
        size_t parentInputIndex,
        double learningRate,
        bool isFirstLayer,
        ActivationType activationType
    )
        : learningRate(learningRate)
        , parentInputIndex(parentInputIndex)
        , isFirstLayer(isFirstLayer)
        , activationType(activationType)
        , ExternalGradient(0)
    {
    }

    void Forward() {
        Output = 0;

        if (activationType == ACTIVATION_SOFTMAX) {
            for (size_t i = 0; i < Inputs.size(); ++i) {
                Output += exp(Inputs[i]->GetOutput());
            }
            Output = exp(Inputs[parentInputIndex]->GetOutput()) / Output;

        } else {
            for (size_t i = 0; i < Inputs.size(); ++i) {
                Output += Weights[i] * Inputs[i]->GetOutput();
            }
            Output = activation(Output);
        }
    }

    void Backward() {
        // gradient will store either an externally set value from ExternalGradient,
        // or a sum of gradients of its parents. These values are never both positive

        double gradient = ExternalGradient;                        // non-zero only for output layer
        for (size_t j = 0; j < Parents.size(); ++j) {
            gradient += Parents[j]->GetGradient(parentInputIndex); // non-zero only for inner layers
        }

        for (size_t i = 0; i < Inputs.size(); ++i) {
            // update gradient by chain rule
            Gradients[i] = gradient * activationDerivative(Output) * Inputs[i]->GetOutput();

            // update weights by gradient descent
            Weights[i] += learningRate * Gradients[i];
        }
    }

    double GetOutput() {
        return Output;
    }

    double GetGradient(size_t index) {
        return Gradients[index];
    }

    vector<double>& GetWeights() {
        return Weights;
    }

    void AddInput(Neuron* n, double w) {
        Inputs.push_back(n);
        Weights.push_back(w);
        Gradients.push_back(0);
    }

    void AddParent(Neuron* n) {
        Parents.push_back(n);
    }

    void SetInput(double val) {
        if (isFirstLayer) {
            Output = val;
        }
    }

    void SetExternalGradient(double grad) {
        ExternalGradient = grad;
    }

private:
    double activation(double x) {
        switch (activationType) {
            case ACTIVATION_NONE:
                return x;
            case ACTIVATION_SIGMA:
                return 1 / (1 + exp(-x));
            case ACTIVATION_RELU:
                if (x > 0) {
                    return x;
                } else {
                    return 0;
                }
            case ACTIVATION_SOFTMAX:
                return x;
            default:
                return x;
        }
    }

    double activationDerivative(double x) {
        switch (activationType) {
            case ACTIVATION_NONE:
                return 1;
            case ACTIVATION_SIGMA:
                return x * (1 - x);
            case ACTIVATION_RELU:
                if (x > 0) {
                    return 1;
                } else {
                    return 0;
                }
            case ACTIVATION_SOFTMAX:
                return x * (1 - x);
            default:
                return 1;
        }
    }

    double learningRate;
    size_t parentInputIndex;

    bool isFirstLayer;
    ActivationType activationType;

    double ExternalGradient;
    double Output;

    vector<double> Weights;
    vector<double> Gradients;

    vector<Neuron*> Inputs;
    vector<Neuron*> Parents;
};

struct LayerSpec {
    size_t Size;
    ActivationType Activation;
};

class NeuralNet {
public:
    NeuralNet(vector<LayerSpec> layers, double learningRate)
        : layers(layers)
    {
        // first add the input layer
        for (size_t i = 0; i < layers[0].Size; ++i) {
            neurons.push_back(new Neuron(i, learningRate, true, layers[0].Activation));
        }

        default_random_engine generator(time(0));
        normal_distribution<double> distribution(0, 1);
  
        size_t previousLayerStartIndex = 0;

        // adding hidden layers and output layer
        for (size_t layerIdx = 1; layerIdx < layers.size(); ++layerIdx) {
            for (size_t j = 0; j < layers[layerIdx].Size; ++j) {
                Neuron* n = new Neuron(j, learningRate, false, layers[layerIdx].Activation);
                neurons.push_back(n);

                // add previous layer neurons as inputs to the current neuron
                for (size_t k = 0; k < layers[layerIdx - 1].Size; ++k) {
                    Neuron* prev = neurons[previousLayerStartIndex + k];

                    n->AddInput(prev, distribution(generator));
                    prev->AddParent(n);
                }
            }

            previousLayerStartIndex += layers[layerIdx - 1].Size;
        }
    }

    ~NeuralNet() {
        for (size_t i = 0; i < neurons.size(); ++i) {
            delete neurons[i];
        }
    }

    vector<double> ForwardPass(const vector<double>& inputs) {
        vector<double> result;

        for (size_t i = 0; i < layers[0].Size; ++i) {
            neurons[i]->SetInput(inputs[i]);
        }

        for (size_t i = layers[0].Size; i < neurons.size(); ++i) {
            neurons[i]->Forward();
        }

        size_t outputLayerStartIndex = neurons.size() - layers.back().Size;

        for (size_t i = outputLayerStartIndex; i < neurons.size(); ++i) {
            result.push_back(neurons[i]->GetOutput());
        }

        return result;
    }

    void DumpWeights() {
        size_t neuronsArrayStartIndex = layers[0].Size;

        cerr << "layer\tneuron\tinput\tweight" << endl;

        for (size_t i = 1; i < layers.size(); ++i) {
            for (size_t j = 0; j < layers[i].Size; ++j) {
                vector<double>& w = neurons[neuronsArrayStartIndex + j]->GetWeights();
                for (size_t k = 0; k < w.size(); ++k) {
                    cerr << i << "\t" << j << "\t" << k << "\t" << w[k] << endl;
                }
            }
            neuronsArrayStartIndex += layers[i].Size;
        }
    }

    vector<double> GetWeights() {
        vector<double> result;

        size_t neuronsArrayStartIndex = layers[0].Size;

        for (size_t i = 1; i < layers.size(); ++i) {
            for (size_t j = 0; j < layers[i].Size; ++j) {
                vector<double>& w = neurons[neuronsArrayStartIndex + j]->GetWeights();
                for (size_t k = 0; k < w.size(); ++k) {
                    result.push_back(w[k]);
                }
            }
            neuronsArrayStartIndex += layers[i].Size;
        }

        return result;
    }

    void BackPropagation(const vector<double>& outputs, const vector<double>& targets) {
        size_t outputLayerStartIndex = neurons.size() - layers.back().Size;

        for (size_t i = 0; i < targets.size(); ++i) {
            neurons[outputLayerStartIndex + i]->SetExternalGradient(targets[i] - outputs[i]);
        }

        for (size_t i = neurons.size() - 1; i >= layers[0].Size; --i) {
            neurons[i]->Backward();
        }
    }

private:
    vector<LayerSpec> layers;
    vector<Neuron*> neurons;
};
