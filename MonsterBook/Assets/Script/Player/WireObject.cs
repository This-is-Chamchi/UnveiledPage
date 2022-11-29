using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WireObject : MonoBehaviour, IWireEffect
{
    [SerializeField] private ParticleSystem hitEffect;


    public void Hit(bool val)
    {
        if (val) hitEffect.Play();
    }


}
