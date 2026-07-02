<?php
namespace App\Core;

use ReflectionClass;
use Exception;

class Container {
    
    /**
     * Resolve a class and automatically inject its dependencies.
     */
    public function resolve($class) {
        $reflection = new ReflectionClass($class);

        if (!$reflection->isInstantiable()) {
            throw new Exception("Class {$class} is not instantiable.");
        }

        $constructor = $reflection->getConstructor();

        if (is_null($constructor)) {
            return new $class;
        }

        $parameters = $constructor->getParameters();
        $dependencies = $this->getDependencies($parameters);

        return $reflection->newInstanceArgs($dependencies);
    }

    /**
     * Recursively resolve dependencies.
     */
    private function getDependencies($parameters) {
        $dependencies = [];

        foreach ($parameters as $parameter) {
            $type = $parameter->getType();

            if ($type === null || $type->isBuiltin()) {
                if ($parameter->isDefaultValueAvailable()) {
                    $dependencies[] = $parameter->getDefaultValue();
                } else {
                    throw new Exception("Cannot resolve parameter {$parameter->name}");
                }
            } else {
                $dependencies[] = $this->resolve($type->getName());
            }
        }

        return $dependencies;
    }
}
