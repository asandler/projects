#pragma once

#include <algorithm>
#include <cmath>
#include <iostream>
#include <random>
#include <vector>

using namespace std;

class Neuron {
public:
    Neuron(size_t parentInputIndex, bool isFirstLayer)
        : StepSize(0.001)
        , ParentInputIndex(parentInputIndex)
        , IsFirstLayer(isFirstLayer)
        , externalGradient(0)
    {
    }

    void Forward() {
        output = 0;
        for (size_t i = 0; i < Inputs.size(); ++i) {
            output += Weights[i] * Inputs[i]->GetOutput();
        }
        output = Sigma(output);
    }

    void Backward() {
        for (size_t i = 0; i < Inputs.size(); ++i) {

            Gradients[i] = externalGradient;
            for (size_t j = 0; j < Parents.size(); ++j) {
                Gradients[i] += Parents[j]->GetGradient(ParentInputIndex);
            }

            Gradients[i] *= output * (1 - output) * Inputs[i]->GetOutput(); //gradient update by chain rule

            Weights[i] += StepSize * Gradients[i]; //weights update by gradient descent
        }
    }

    double GetOutput() {
        return output;
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
        if (IsFirstLayer) {
            output = val;
        }
    }

    void SetExternalGradient(double grad) {
        externalGradient = grad;
    }

private:
    double Sigma(double x) {
        return 1 / (1 + exp(-x));
    }

    double output;
    double StepSize;

    size_t ParentInputIndex;
    bool IsFirstLayer;

    vector<double> Weights;
    vector<double> Gradients;
    double externalGradient;

    vector<Neuron*> Inputs;
    vector<Neuron*> Parents;
};

class NeuralNet {
public:
    /*
        Construction of a fully connected multi-layer neural network.
        layersSize - array with layers sizes,
        layersSize[0] - size of input layer,
        layersSize[1] - size of 1st hidden layer,
        ...
        layersSize[last] - size of output layer
    */
    NeuralNet(vector<size_t> layersSize)
        : LayersSize(layersSize)
    {
        for (size_t i = 0; i < LayersSize[0]; ++i) { // add input layer
            Neurons.push_back(new Neuron(i, true));
        }

        default_random_engine generator(time(0));
        normal_distribution<double> distribution(0, 1);
  
        // adding hidden layers and output layer
        size_t neuronsArrayStartIndex = 0;
        for (size_t i = 1; i < layersSize.size(); ++i) { // iterate over layers one by one

            for (size_t j = 0; j < layersSize[i]; ++j) {
                Neuron* n = new Neuron(j, false);
                Neurons.push_back(n);

                for (size_t k = 0; k < layersSize[i - 1]; ++k) { // add connections between new neuron and i - 1 layer
                    n->AddInput(Neurons[neuronsArrayStartIndex + k], distribution(generator));
                    Neurons[neuronsArrayStartIndex + k]->AddParent(n);
                }
            }

            neuronsArrayStartIndex += layersSize[i - 1];
        }
    }

    ~NeuralNet() {
        for (size_t i = 0; i < Neurons.size(); ++i) {
            delete Neurons[i];
        }
    }

    void ForwardPass(const vector<double>& inputs) {
        for (size_t i = 0; i < LayersSize[0]; ++i) {
            Neurons[i]->SetInput(inputs[i]);
        }
        for (size_t i = LayersSize[0]; i < Neurons.size(); ++i) {
            Neurons[i]->Forward();
        }
    }

    vector<double> GetOutput() {
        vector<double> answer;

        size_t outputLayerStartIndex = Neurons.size() - LayersSize[LayersSize.size() - 1];

        for (size_t i = outputLayerStartIndex; i < Neurons.size(); ++i) {
            answer.push_back(Neurons[i]->GetOutput());
        }

        return answer;
    }

    void DumpWeights() {
        size_t neuronsArrayStartIndex = LayersSize[0];
        for (size_t i = 1; i < LayersSize.size(); ++i) {

            for (size_t j = 0; j < LayersSize[i]; ++j) {

                vector<double>& w = Neurons[neuronsArrayStartIndex + j]->GetWeights();
                for (size_t k = 0; k < w.size(); ++k) {
                    cout << i << "\t" << j << "\t" << k << "\t" << w[k] << endl;
                }
            }

            neuronsArrayStartIndex += LayersSize[i];
        }
    }

    void BackPropagation(const vector<double>& f_a, const vector<double>& f_t) {
        // calc the difference D between f_t and f_a = ||(f_t, f_a)|| (mean square error)
        // ||(x, y)|| = sqrt(sum_i=1^n(x_i - y_i)^2 / n)
        // and then differentiate D along every output neuron

        size_t outputLayerStartIndex = Neurons.size() - LayersSize[LayersSize.size() - 1];
        for (size_t i = 0; i < f_t.size(); ++i) {
            Neurons[outputLayerStartIndex + i]->SetExternalGradient(f_t[i] - f_a[i]);
        }

        for (size_t i = Neurons.size() - 1; i >= LayersSize[0]; --i) {
            Neurons[i]->Backward();
        }
    }

private:
    vector<size_t> LayersSize;
    vector<Neuron*> Neurons;
};
