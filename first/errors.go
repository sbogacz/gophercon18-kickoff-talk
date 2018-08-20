package main

import (
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

type notFoundError interface {
	NotFound()
}

type notFoundErr struct {
	err error
}

func (ne notFoundErr) Error() string {
	return ne.err.Error()
}

func (ne notFoundErr) NotFound() {}

type internalServerError interface {
	InternalServer()
}

type internalServerErr struct {
	err error
}

func (ie internalServerErr) Error() string {
	return ie.err.Error()
}

func (ie internalServerErr) InternalServer() {}

type badRequestError interface {
	BadRequest()
}

type badRequestErr struct {
	err error
}

func (be badRequestErr) Error() string {
	return be.err.Error()
}

func (be badRequestErr) BadRequest() {}

func errorResponse(err error) *events.APIGatewayProxyResponse {
	var code int
	switch err.(type) {
	case badRequestError:
		code = http.StatusBadRequest
	case internalServerError:
		code = http.StatusInternalServerError
	case notFoundError:
		code = http.StatusNotFound
	}
	return &events.APIGatewayProxyResponse{
		StatusCode: code,
	}
}
