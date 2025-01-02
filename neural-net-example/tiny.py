#!/usr/bin/env python3

from __future__ import print_function

import sys
import os
import time
import random

import numpy as np
import theano
import theano.tensor as T

import lasagne

TRAIN_SIZE = 10000
VAL_SIZE   = 5000
TEST_SIZE  = 3000
TOTAL_SIZE = TRAIN_SIZE + VAL_SIZE + TEST_SIZE
BATCH_SIZE = 500


def make_dataset():
    data = np.empty(shape=(TOTAL_SIZE, 2))
    targets = np.empty(shape=(TOTAL_SIZE), dtype=np.int32)

    for i in range(TOTAL_SIZE):
        x, y = random.uniform(-2, 2), random.uniform(-2, 2)
        data[i] = [x, y]
        if x < y and -x < y:
            targets[i] = 0
        elif x > 0:
            targets[i] = 1
        else:
            targets[i] = 2

    x_train, x_val, x_test = data[0:TRAIN_SIZE], data[TRAIN_SIZE:TRAIN_SIZE+VAL_SIZE], data[TRAIN_SIZE+VAL_SIZE:]
    y_train, y_val, y_test = targets[0:TRAIN_SIZE], targets[TRAIN_SIZE:TRAIN_SIZE+VAL_SIZE], targets[TRAIN_SIZE+VAL_SIZE:]

    return x_train, y_train, x_val, y_val, x_test, y_test


def build_mlp(input_var):
    l_in = lasagne.layers.InputLayer(shape=(None, 2), input_var=input_var, W=lasagne.init.GlorotUniform())
    # rectify is faster but we keep sigmoid for learning purposes
    l_hid1 = lasagne.layers.DenseLayer(l_in, num_units=4, nonlinearity=lasagne.nonlinearities.sigmoid, W=lasagne.init.GlorotUniform())
    l_hid2 = lasagne.layers.DenseLayer(l_hid1, num_units=4, nonlinearity=lasagne.nonlinearities.sigmoid, W=lasagne.init.GlorotUniform())
    l_out = lasagne.layers.DenseLayer(l_hid2, num_units=3, nonlinearity=lasagne.nonlinearities.softmax, W=lasagne.init.GlorotUniform())

    return l_out


def iterate_minibatches(inputs, targets, batchsize, shuffle=False):
    assert len(inputs) == len(targets)
    if shuffle:
        indices = np.arange(len(inputs))
        np.random.shuffle(indices)
    for start_idx in range(0, len(inputs) - batchsize + 1, batchsize):
        if shuffle:
            excerpt = indices[start_idx:start_idx + batchsize]
        else:
            excerpt = slice(start_idx, start_idx + batchsize)
        yield inputs[excerpt], targets[excerpt]


def main(num_epochs=50):
    print("Loading data...")
    X_train, y_train, X_val, y_val, X_test, y_test = make_dataset()

    # Prepare Theano variables for inputs and targets
    input_var = T.matrix('inputs')
    target_var = T.ivector('targets')

    print("Building model and compiling functions...")
    network = build_mlp(input_var)

    # Create a loss expression for training, i.e., a scalar objective we want
    # to minimize (for our multi-class problem, it is the cross-entropy loss):
    prediction = lasagne.layers.get_output(network)
    loss = lasagne.objectives.categorical_crossentropy(prediction, target_var)
    loss = loss.mean()

    # Create update expressions for training, i.e., how to modify the
    # parameters at each training step. Here, we'll use Stochastic Gradient
    # Descent (SGD) with Nesterov momentum, but Lasagne offers plenty more.
    params = lasagne.layers.get_all_params(network, trainable=True)
    # updates = lasagne.updates.nesterov_momentum(loss, params, learning_rate=0.01, momentum=0.9)
    updates = lasagne.updates.sgd(loss, params, learning_rate=0.01)

    test_prediction = lasagne.layers.get_output(network, deterministic=True)
    test_loss = lasagne.objectives.categorical_crossentropy(test_prediction, target_var)
    test_loss = test_loss.mean()
    # As a bonus, also create an expression for the classification accuracy:
    test_acc = T.mean(T.eq(T.argmax(test_prediction, axis=1), target_var), dtype=theano.config.floatX)

    train_fn = theano.function([input_var, target_var], loss, updates=updates)
    val_fn   = theano.function([input_var, target_var], [test_loss, test_acc])

    print("Starting training...")

    for epoch in range(num_epochs):
        train_err = 0
        train_batches = 0
        start_time = time.time()
        for batch in iterate_minibatches(X_train, y_train, BATCH_SIZE, shuffle=True):
            inputs, targets = batch
            train_err += train_fn(inputs, targets)
            train_batches += 1

        val_err = 0
        val_acc = 0
        val_batches = 0
        for batch in iterate_minibatches(X_val, y_val, BATCH_SIZE, shuffle=False):
            inputs, targets = batch
            err, acc = val_fn(inputs, targets)
            val_err += err
            val_acc += acc
            val_batches += 1

        print("Epoch {} of {} took {:.3f}s".format(epoch + 1, num_epochs, time.time() - start_time))
        print("  training loss:\t\t{:.6f}".format(train_err / train_batches))
        print("  validation loss:\t\t{:.6f}".format(val_err / val_batches))
        print("  validation accuracy:\t\t{:.2f} %".format(val_acc / val_batches * 100))

    # After training, we compute and print the test error:
    test_err = 0
    test_acc = 0
    test_batches = 0
    for batch in iterate_minibatches(X_test, y_test, BATCH_SIZE, shuffle=False):
        inputs, targets = batch
        err, acc = val_fn(inputs, targets)
        test_err += err
        test_acc += acc
        test_batches += 1

    print("Final results:")
    print("  test loss:\t\t\t{:.6f}".format(test_err / test_batches))
    print("  test accuracy:\t\t{:.2f} %".format(test_acc / test_batches * 100))


if __name__ == '__main__':
    if ('--help' in sys.argv) or ('-h' in sys.argv):
        print("Trains a simple neural network")
        print("Usage: %s [EPOCHS]" % sys.argv[0])
        print()
        print("EPOCHS: number of training epochs to perform (default: 500)")
    else:
        kwargs = {}
        if len(sys.argv) > 1:
            kwargs['num_epochs'] = int(sys.argv[1])
        main(**kwargs)
