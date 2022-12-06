using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_Grogy_State : FSM_State<Anna>
{
    private bool onetime = false;
    private float time;
    private bool OneTimeSoundPlay = false;
    private float circleSizeTimer;
    private float circle_IntensityTimer;
    //private int fallSoundID;

    static readonly Anna_Grogy_State instance = new Anna_Grogy_State();
    public static Anna_Grogy_State Instance
    {
        get { return instance; }
    }

    public override void EnterState(Anna _Anna)
    {
        GameManager.SetInGameInput(false);
        _Anna.BodyFire.SetActive(false);
        _Anna.ThirdEye.SetActive(false);

        _Anna.GroundLanding = false;
        OneTimeSoundPlay = false;
        _Anna.UI.SetActive(false);
        _Anna.Anna_Ani.SetTrigger("Groggy_Start");
        time = 1;
        onetime = false;
    }

    public override void ExitState(Anna _Anna)
    {
    }

    public override void UpdateState(Anna _Anna)
    {

        if (circleSizeTimer < 0f)
        {

        }
        else
        {
            circleSizeTimer -= Time.deltaTime / _Anna.circleSizeSpeed;
        }
        _Anna.Circle.transform.localScale = new Vector3(circleSizeTimer, circleSizeTimer, circleSizeTimer);


        if (circle_IntensityTimer < 0)
        {

        }
        else
        {
            circle_IntensityTimer -= Time.deltaTime * _Anna.circleIntensitySpeed;
        }
        _Anna.Circle.GetComponent<MeshRenderer>().material.SetFloat("_Color_Intensity", circle_IntensityTimer);







        time -= Time.deltaTime;
        if(_Anna.AnnaFalling)
        {
            if(OneTimeSoundPlay == false)
            {
                //fallSoundID = _Anna.AnnaSoundLoop("2StageAnna_GroggyScream");
                OneTimeSoundPlay = true;
            }
            _Anna.transform.position = new Vector3(_Anna.transform.position.x, _Anna.transform.position.y - _Anna.DownSpeed, _Anna.transform.position.z);
        }

        if(_Anna.finishAttackAble == true)
        {

        }


        if(_Anna.GroundLanding == true)
        {
            if(onetime == false)
            {
                _Anna.Anna_Ani.SetTrigger("Landing_Ground");
                //_Anna.AnnaSoundLoopEnd(fallSoundID);
                _Anna.GroggySoundID = _Anna.AnnaSoundLoop("2StageAnna_Groggy");
                _Anna.finishAttackAble = true;
                _Anna.AnnaFalling = false;
                onetime = true;
            }
            else
            {

            }
            
  
        }

    }





}
