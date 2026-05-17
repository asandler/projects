#pragma once

#include <algorithm>
#include <cmath>
#include <ctime>
#include <iostream>
#include <random>
#include <stdexcept>
#include <vector>

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
        , Delta(0)
        , Output(0)
    {
    }

    void Forward() {
        Output = 0;

        if (activationType == ACTIVATION_SOFTMAX) {
            Output = weightedInput();
        } else {
            Output = activation(weightedInput());
        }
    }

    void ComputeHiddenDelta() {
        double downstreamDelta = 0;
        for (size_t j = 0; j < Parents.size(); ++j) {
            downstreamDelta += Parents[j]->GetWeight(parentInputIndex) * Parents[j]->GetDelta();
        }

        Delta = activationDerivative(Output) * downstreamDelta;
    }

    void UpdateWeights() {
        for (size_t i = 0; i < Inputs.size(); ++i) {
            Gradients[i] = Delta * Inputs[i]->GetOutput();
            Weights[i] += learningRate * Gradients[i];
        }
    }

    double GetOutput() const {
        return Output;
    }

    void SetOutput(double val) {
        Output = val;
    }

    double GetGradient(size_t index) const {
        return Gradients[index];
    }

    double GetWeight(size_t index) const {
        return Weights[index];
    }

    std::vector<double>& GetWeights() {
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
        Delta = grad;
    }

    void SetDelta(double delta) {
        Delta = delta;
    }

    void SetOutputLayerDelta(double target) {
        Delta = (target - Output) * activationDerivative(Output);
    }

    double GetDelta() const {
        return Delta;
    }

private:
    double weightedInput() const {
        double result = 0;

        for (size_t i = 0; i < Inputs.size(); ++i) {
            result += Weights[i] * Inputs[i]->GetOutput();
        }

        return result;
    }

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

    double activationDerivative(double x) const {
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
                return 1;
            default:
                return 1;
        }
    }

    double learningRate;
    size_t parentInputIndex;

    bool isFirstLayer;
    ActivationType activationType;

    double Delta;
    double Output;

    std::vector<double> Weights;
    std::vector<double> Gradients;

    std::vector<Neuron*> Inputs;
    std::vector<Neuron*> Parents;
};

struct LayerSpec {
    size_t Size;
    ActivationType Activation;
};

class NeuralNet {
public:
    NeuralNet(std::vector<LayerSpec> layers, double learningRate)
        : layers(layers)
    {
        validateLayers();

        // first add the input layer
        for (size_t i = 0; i < layers[0].Size; ++i) {
            neurons.push_back(new Neuron(i, learningRate, true, layers[0].Activation));
        }

        std::default_random_engine generator(static_cast<unsigned>(std::time(nullptr)));
        std::normal_distribution<double> distribution(0, 1);
  
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

    NeuralNet(const NeuralNet&) = delete;
    NeuralNet& operator=(const NeuralNet&) = delete;

    std::vector<double> ForwardPass(const std::vector<double>& inputs) {
        if (inputs.size() != layers[0].Size) {
            throw std::runtime_error("ForwardPass: input size does not match input layer size");
        }

        std::vector<double> result;

        for (size_t i = 0; i < layers[0].Size; ++i) {
            neurons[i]->SetInput(inputs[i]);
        }

        for (size_t layerIdx = 1; layerIdx < layers.size(); ++layerIdx) {
            size_t layerStartIndex = LayerStartIndex(layerIdx);

            for (size_t j = 0; j < layers[layerIdx].Size; ++j) {
                neurons[layerStartIndex + j]->Forward();
            }

            if (layers[layerIdx].Activation == ACTIVATION_SOFTMAX) {
                NormalizeSoftmaxLayer(layerIdx);
            }
        }

        size_t outputLayerStartIndex = neurons.size() - layers.back().Size;

        for (size_t i = outputLayerStartIndex; i < neurons.size(); ++i) {
            result.push_back(neurons[i]->GetOutput());
        }

        return result;
    }

    void DumpWeights() {
        size_t neuronsArrayStartIndex = layers[0].Size;

        std::cerr << "layer\tneuron\tinput\tweight" << std::endl;

        for (size_t i = 1; i < layers.size(); ++i) {
            for (size_t j = 0; j < layers[i].Size; ++j) {
                std::vector<double>& w = neurons[neuronsArrayStartIndex + j]->GetWeights();
                for (size_t k = 0; k < w.size(); ++k) {
                    std::cerr << i << "\t" << j << "\t" << k << "\t" << w[k] << std::endl;
                }
            }
            neuronsArrayStartIndex += layers[i].Size;
        }
    }

    std::vector<double> GetWeights() {
        std::vector<double> result;

        size_t neuronsArrayStartIndex = layers[0].Size;

        for (size_t i = 1; i < layers.size(); ++i) {
            for (size_t j = 0; j < layers[i].Size; ++j) {
                std::vector<double>& w = neurons[neuronsArrayStartIndex + j]->GetWeights();
                for (size_t k = 0; k < w.size(); ++k) {
                    result.push_back(w[k]);
                }
            }
            neuronsArrayStartIndex += layers[i].Size;
        }

        return result;
    }

    void BackPropagation(const std::vector<double>& outputs, const std::vector<double>& targets) {
        size_t outputLayerStartIndex = neurons.size() - layers.back().Size;

        if (outputs.size() != layers.back().Size || targets.size() != layers.back().Size) {
            throw std::runtime_error("BackPropagation: output and target sizes must match output layer size");
        }

        for (size_t i = 0; i < targets.size(); ++i) {
            if (layers.back().Activation == ACTIVATION_SOFTMAX) {
                // Softmax with cross-entropy: the output-layer delta simplifies to target - output.
                neurons[outputLayerStartIndex + i]->SetDelta(targets[i] - outputs[i]);
            } else {
                neurons[outputLayerStartIndex + i]->SetOutputLayerDelta(targets[i]);
            }
        }

        for (size_t layerIdx = layers.size() - 1; layerIdx > 1; --layerIdx) {
            size_t hiddenLayerIdx = layerIdx - 1;
            size_t hiddenLayerStartIndex = LayerStartIndex(hiddenLayerIdx);

            for (size_t i = 0; i < layers[hiddenLayerIdx].Size; ++i) {
                neurons[hiddenLayerStartIndex + i]->ComputeHiddenDelta();
            }
        }

        for (size_t layerIdx = 1; layerIdx < layers.size(); ++layerIdx) {
            size_t layerStartIndex = LayerStartIndex(layerIdx);

            for (size_t i = 0; i < layers[layerIdx].Size; ++i) {
                neurons[layerStartIndex + i]->UpdateWeights();
            }
        }
    }

private:
    void validateLayers() const {
        if (layers.empty()) {
            throw std::runtime_error("NeuralNet: at least one layer is required");
        }

        for (size_t i = 0; i < layers.size(); ++i) {
            if (layers[i].Size == 0) {
                throw std::runtime_error("NeuralNet: layer size must be positive");
            }

            if (i + 1 < layers.size() && layers[i].Activation == ACTIVATION_SOFTMAX) {
                throw std::runtime_error("NeuralNet: softmax is only supported on the output layer");
            }
        }
    }

    size_t LayerStartIndex(size_t layerIdx) const {
        size_t result = 0;

        for (size_t i = 0; i < layerIdx; ++i) {
            result += layers[i].Size;
        }

        return result;
    }

    void NormalizeSoftmaxLayer(size_t layerIdx) {
        size_t layerStartIndex = LayerStartIndex(layerIdx);
        double maxLogit = neurons[layerStartIndex]->GetOutput();

        for (size_t i = 1; i < layers[layerIdx].Size; ++i) {
            maxLogit = std::max(maxLogit, neurons[layerStartIndex + i]->GetOutput());
        }

        double denominator = 0;
        for (size_t i = 0; i < layers[layerIdx].Size; ++i) {
            denominator += std::exp(neurons[layerStartIndex + i]->GetOutput() - maxLogit);
        }

        for (size_t i = 0; i < layers[layerIdx].Size; ++i) {
            double numerator = std::exp(neurons[layerStartIndex + i]->GetOutput() - maxLogit);
            neurons[layerStartIndex + i]->SetOutput(numerator / denominator);
        }
    }

    std::vector<LayerSpec> layers;
    std::vector<Neuron*> neurons;
};
