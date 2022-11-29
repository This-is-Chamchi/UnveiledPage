using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_Phase2Change_State : FSM_State<Anna>     //Anna2PhaseEvent
{
    private bool OnSPMovePoint;
    private bool OffHpEffect;
    private float Halo_DissolveTimer;


    private float time = 0;
    private Vector3 CurrentPosition;
    static readonly Anna_Phase2Change_State instance = new Anna_Phase2Change_State();
    public static Anna_Phase2Change_State Instance
    {
        get { return instance; }
    }

    public override void EnterState(Anna _Anna)
    {
        GameManager.SetInGameInput(false);
        _Anna.Isinvincibility = true;
        CurrentPosition = _Anna.transform.position;
        OnSPMovePoint = false;
        OffHpEffect = false;
        time = 0;
        _Anna.Anna_Ani.Play("Idle");
        Halo_DissolveTimer = _Anna.Halo.GetComponent<MeshRenderer>().material.GetFloat("_Mask_Dissolve_Control");

    }

    public override void UpdateState(Anna _Anna)
    {
        if (OnSPMovePoint == false)
        {
            var m_fMaxSpeed = _Anna.MoveSpeed;

            time += Time.deltaTime * m_fMaxSpeed;

            _Anna.transform.position = Vector3.Lerp(CurrentPosition, _Anna.SpMovePoint.transform.position, time);

            if (time >= 1.0f)
            {
                time = -2f;
                OnSPMovePoint = true;
            }
            return;
        }

        if (OffHpEffect == false && OnSPMovePoint == true)
        {
            Halo_DissolveTimer -= Time.deltaTime;
            _Anna.Halo.GetComponent<MeshRenderer>().material.SetFloat("_Mask_Dissolve_Control", Halo_DissolveTimer);
            if(Halo_DissolveTimer < -0.2f)
            {
                _Anna.BodyFire.GetComponent<ParticleSystem>().Play();
                _Anna.AnnaBandage.SetActive(false);
                OffHpEffect = true;
            }
        }

        if(OffHpEffect == true && OnSPMovePoint == true)
        {
            time += Time.deltaTime;
            if(time > 0 && time < 1)
            {
                Debug.Log("불타는 이펙트 값 증가중");
                _Anna.BodyFire.GetComponent<ParticleSystemRenderer>().material.SetFloat("_Dissolve_Value",time);
            }

            if(time > -1 && time < 1)
            {
                Debug.Log("안광 생성중");
                _Anna.ThirdEye.GetComponent<MeshRenderer>().material.SetFloat("_Mask_Dissolve_Control", time);
            }

            if(time < 2)
            {
            }
            else
            {
                _Anna.ChangeState_Idle();
            }
            
        }




    }

    public override void ExitState(Anna _Anna)
    {
        GameManager.SetInGameInput(true);
        _Anna.Isinvincibility = false;
    }
}
